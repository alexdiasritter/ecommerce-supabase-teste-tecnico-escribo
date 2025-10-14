CREATE OR REPLACE VIEW public.detalhes_pedidos AS
SELECT
  p.id AS pedido_id,
  p.status,
  p.total,
  p.created_at AS data_pedido,
  p.cliente_id,
  c.nome_completo AS nome_cliente,
  
  (
    SELECT count(*)
    FROM public.itens_pedidos ip
    WHERE ip.pedido_id = p.id
  ) AS quantidade_itens
  
FROM
  public.pedidos p
  JOIN public.clientes c ON p.cliente_id = c.id;