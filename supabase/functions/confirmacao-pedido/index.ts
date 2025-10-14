import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import nodemailer from 'https://esm.sh/nodemailer'

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

    const { data: pedido, error: pedidoError } = await supabaseAdmin
      .from('detalhes_pedidos')
      .select('cliente_id, nome_cliente, total, data_pedido') 
      .eq('pedido_id', pedido_id)
      .single()

    if (pedidoError) throw pedidoError
    
    const { data: userData, error: userError } = await supabaseAdmin.auth.admin.getUserById(pedido.cliente_id)
    if(userError) throw userError
    const emailCliente = userData.user.email

    const gmailUser = Deno.env.get('GMAIL_USER')!
    const gmailAppPassword = Deno.env.get('GMAIL_APP_PASSWORD')!

    const transporter = nodemailer.createTransport({
      host: "smtp.gmail.com",
      port: 465, 
      secure: true, 
      auth: {
        user: gmailUser,
        pass: gmailAppPassword, 
      },
    });

    const mailOptions = {
      from: `"Equipe E-commerce" <${gmailUser}>`, 
      to: emailCliente,
      subject: `Confirmação do seu pedido ${pedido_id}`,
      html: `<h1>Olá, ${pedido.nome_cliente}!</h1>
             <p>Seu pedido foi confirmado com sucesso.</p>
             <p>Total: R$ ${pedido.total}</p>
             <p>Data: ${new Date(pedido.data_pedido).toLocaleDateString()}</p>
             <p>Obrigado por comprar conosco!</p>`,
    }

    const info = await transporter.sendMail(mailOptions);
    console.log("E-mail enviado: %s", info.messageId);


    return new Response(JSON.stringify({ message: "E-mail de confirmação enviado com sucesso!" }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error) {
    console.error(error); 
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500, 
    })
  }
})