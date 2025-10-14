CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


CREATE TYPE public.order_status AS ENUM ('pendente', 'pago', 'enviado', 'cancelado');

CREATE TABLE public.produtos (
  id uuid NOT NULL PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  nome text NOT NULL CHECK (char_length(nome) > 3),
  descricao text,
  preco numeric(10, 2) NOT NULL CHECK (preco >= 0),
  estoque integer NOT NULL DEFAULT 0 CHECK (estoque >= 0),
  created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.clientes (
  id uuid NOT NULL PRIMARY KEY,
  nome_completo text,
  endereco jsonb,
  telefone text
);
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.pedidos (
  id uuid NOT NULL PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  cliente_id uuid NOT NULL,
  status public.order_status NOT NULL DEFAULT 'pendente',
  total numeric(10, 2) DEFAULT 0.00 CHECK (total >= 0),
  created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.pedidos ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.itens_pedidos (
  pedido_id uuid NOT NULL,
  produto_id uuid NOT NULL,
  quantidade integer NOT NULL CHECK (quantidade > 0),
  preco_unitario numeric(10, 2) NOT NULL CHECK (preco_unitario >= 0),
  PRIMARY KEY (pedido_id, produto_id)
);
ALTER TABLE public.itens_pedidos ENABLE ROW LEVEL SECURITY;


ALTER TABLE public.clientes
  ADD CONSTRAINT clientes_id_fkey FOREIGN KEY (id)
  REFERENCES auth.users (id) ON DELETE CASCADE;

ALTER TABLE public.pedidos
  ADD CONSTRAINT pedidos_cliente_id_fkey FOREIGN KEY (cliente_id)
  REFERENCES public.clientes (id);

ALTER TABLE public.itens_pedidos
  ADD CONSTRAINT itens_pedidos_pedido_id_fkey FOREIGN KEY (pedido_id)
  REFERENCES public.pedidos (id) ON DELETE CASCADE;

ALTER TABLE public.itens_pedidos
  ADD CONSTRAINT itens_pedidos_produto_id_fkey FOREIGN KEY (produto_id)
  REFERENCES public.produtos (id);