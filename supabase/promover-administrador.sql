-- Execute somente depois de criar e confirmar a conta com este e-mail.
-- Este comando promove exclusivamente esse perfil para administrador.
update public.profiles
set role = 'admin',
    approval_status = 'approved',
    updated_at = now()
where lower(email) = lower('Mestrelegalbacanamaneiro@gmail.com');

-- Confirme que exatamente o perfil esperado foi promovido:
select id, email, role, approval_status
from public.profiles
where lower(email) = lower('Mestrelegalbacanamaneiro@gmail.com');