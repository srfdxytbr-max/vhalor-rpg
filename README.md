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

## Limitações do protótipo
Este beta não tem backend. Contas e relatos ficam apenas no armazenamento local do navegador; não são sincronizados entre dispositivos nem enviados ao administrador. O hash no cliente é apenas demonstrativo e não substitui autenticação segura no servidor. Não utilize senhas reais ou reutilizadas. Antes do lançamento, integrar autenticação server-side, banco de dados, sessões seguras e endpoint de suporte.

A representação do planeta é provisória, feita em CSS. A arte definitiva deve respeitar a geografia de Vhalor que ainda estamos desenvolvendo.
