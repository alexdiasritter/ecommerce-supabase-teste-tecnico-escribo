CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER 
AS $$
BEGIN
  -- Insere uma nova linha na tabela 'clientes', usando o ID e o e-mail do novo usuário
  -- que acabou de ser criado na tabela 'auth.users'.
  INSERT INTO public.clientes (id)
  VALUES (NEW.id);
  
  RETURN NEW;
END;
$$;


-- Este trigger chama a função handle_new_user() DEPOIS que um novo usuário é inserido na tabela auth.users.
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE PROCEDURE public.handle_new_user();