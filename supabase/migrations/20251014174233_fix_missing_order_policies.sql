/**
 * =================================================================================
 * Políticas de RLS para a Tabela: pedidos
 * =================================================================================
 */

CREATE POLICY "Permitir que usuários criem seus próprios pedidos"
ON public.pedidos
FOR INSERT
WITH CHECK (auth.uid() = cliente_id);

CREATE POLICY "Permitir que usuários leiam seus próprios pedidos"
ON public.pedidos
FOR SELECT
USING (auth.uid() = cliente_id);


/**
 * =================================================================================
 * Políticas de RLS para a Tabela: itens_pedidos
 * =================================================================================
 */

CREATE POLICY "Permitir que usuários adicionem itens aos seus pedidos"
ON public.itens_pedidos
FOR INSERT
WITH CHECK (
  auth.uid() = (SELECT cliente_id FROM public.pedidos WHERE id = pedido_id)
);

CREATE POLICY "Permitir que usuários leiam os itens dos seus pedidos"
ON public.itens_pedidos
FOR SELECT
USING (
  auth.uid() = (SELECT cliente_id FROM public.pedidos WHERE id = pedido_id)
);