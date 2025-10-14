CREATE OR REPLACE FUNCTION public.handle_update_order_total()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.pedidos
  SET total = (
    SELECT COALESCE(SUM(quantidade * preco_unitario), 0)
    FROM public.itens_pedidos
    WHERE pedido_id = COALESCE(NEW.pedido_id, OLD.pedido_id)
  )
  WHERE id = COALESCE(NEW.pedido_id, OLD.pedido_id);

  IF (TG_OP = 'DELETE') THEN
    RETURN OLD;
  ELSE
    RETURN NEW;
  END IF;
END;
$$;

CREATE TRIGGER on_itens_pedidos_change
  AFTER INSERT OR UPDATE OR DELETE
  ON public.itens_pedidos
  FOR EACH ROW
  EXECUTE PROCEDURE public.handle_update_order_total();