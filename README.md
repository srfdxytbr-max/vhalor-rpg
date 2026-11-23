# Vhalor RPG — Beta

Primeiro protótipo do portal de Vhalor.

## Publicar
O arquivo `index.html` pode ser servido pelo GitHub Pages (Settings → Pages → Deploy from a branch → main → /(root)).

## Incluído
- Tela inicial espacial com planeta estilizado e duas luas.
- Ações Iniciar e Suporte.
- Telas demonstrativas de cadastro e login.
- Transição de aproximação do planeta após autenticação local.
- Formulário de suporte demonstrativo.
- Layout responsivo para celular e desktop.

## Backend e controle de acesso (em preparação)
A arquitetura escolhida é Supabase. O arquivo `supabase/schema.sql` cria:
- Perfis de usuário com e-mail, função e estado de aprovação.
- Novas contas com estado `pending` por padrão.
- Fichas de personagem vinculadas ao dono.
- Conteúdo do sistema de RPG.
- Políticas RLS: jogadores aprovados leem o sistema e gerenciam suas próprias fichas; administradores podem aprovar/bloquear contas e editar dados de todos.
- A leitura de e-mails de outros usuários fica restrita ao administrador.

### Configuração necessária
1. Crie um projeto no Supabase.
2. Abra SQL Editor e execute o conteúdo de `supabase/schema.sql`.
3. Crie a conta do administrador com o e-mail escolhido.
4. Execute no SQL Editor o comando de bootstrap de administrador comentado no final do arquivo SQL (confira o e-mail antes de executar).
5. Nas configurações de autenticação, decida se a confirmação por e-mail ficará desativada para o beta. Se ficar ativada, o endereço precisa receber o link de confirmação.
6. Depois, conecte o frontend usando apenas a Project URL e a chave pública/anon (ou publishable). Nunca coloque a chave `service_role` no navegador ou no GitHub.

**Importante:** o frontend atual ainda é demonstrativo e não está conectado ao Supabase. Até a integração ser concluída, não há cadastro online real, aprovação efetiva, painel administrativo funcional nem armazenamento compartilhado. Não use senhas reais ou reutilizadas nesse protótipo.

## Limitações do protótipo
Este beta ainda não tem backend conectado. O formulário de suporte também é demonstrativo e não envia mensagens ao administrador.
