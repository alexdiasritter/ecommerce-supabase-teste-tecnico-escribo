import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { pedido_id } = await req.json()
    if (!pedido_id) {
      throw new Error("O 'pedido_id' é obrigatório.")
    }

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    const { data: itens, error } = await supabaseAdmin
      .from('itens_pedidos')
      .select(`
        quantidade,
        preco_unitario,
        produtos ( nome )
      `)
      .eq('pedido_id', pedido_id)

    if (error) throw error

    let csv = 'Produto,Quantidade,PrecoUnitario\n'
    
    for (const item of itens) {
      const nomeProduto = item.produtos.nome.includes(',') ? `"${item.produtos.nome}"` : item.produtos.nome
      csv += `${nomeProduto},${item.quantidade},${item.preco_unitario}\n`
    }

    const headers = {
      ...corsHeaders,
      'Content-Type': 'text/csv',
      'Content-Disposition': `attachment; filename="pedido-${pedido_id}.csv"`,
    }

    return new Response(csv, { headers, status: 200 })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})