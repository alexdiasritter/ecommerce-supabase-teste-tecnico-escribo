/**
 * =================================================================================
 * Políticas de RLS para a Tabela: produtos
 * =================================================================================
 */

-- Política 1: Permitir que qualquer pessoa (mesmo não autenticada) veja os produtos.
CREATE POLICY "Permitir leitura pública de produtos"
ON public.produtos
FOR SELECT
USING (true);




/**
 * =================================================================================
 * Políticas de RLS para a Tabela: clientes
 * =================================================================================
 */

-- Política 1: Permitir que um usuário veja seu PRÓPRIO perfil.
-- A função `auth.uid()` retorna o ID do usuário que está fazendo a requisição.
CREATE POLICY "Permitir que usuários leiam seus próprios dados"
ON public.clientes
FOR SELECT
USING (auth.uid() = id);

-- Política 2: Permitir que um usuário atualize seu PRÓPRIO perfil.
CREATE POLICY "Permitir que usuários atualizem seus próprios dados"
ON public.clientes
FOR UPDATE
USING (auth.uid() = id);