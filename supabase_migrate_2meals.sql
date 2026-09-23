-- Migration: รองรับการเช็กอาหาร 2 มื้อ (เช้า / เย็น)
alter table public.breakfast_records
  add column if not exists meal text;

update public.breakfast_records
set meal = 'เช้า'
where meal is null;

alter table public.breakfast_records
  alter column meal set default 'เช้า';

alter table public.breakfast_records
  alter column meal set not null;

alter table public.breakfast_records
  drop constraint if exists breakfast_records_meal_check;

alter table public.breakfast_records
  add constraint breakfast_records_meal_check
  check (meal in ('เช้า','เย็น'));

alter table public.breakfast_records
  drop constraint if exists breakfast_records_pkey;

alter table public.breakfast_records
  add constraint breakfast_records_pkey
  primary key (student_id, date, meal);

create index if not exists idx_breakfast_records_date_meal
  on public.breakfast_records(date, meal);

alter table public.breakfast_records enable row level security;

drop policy if exists breakfast_select_public on public.breakfast_records;
drop policy if exists breakfast_insert_public on public.breakfast_records;
drop policy if exists breakfast_update_public on public.breakfast_records;

create policy breakfast_select_public
  on public.breakfast_records for select
  to anon, authenticated using (true);

create policy breakfast_insert_public
  on public.breakfast_records for insert
  to anon, authenticated
  with check (status = 'กิน' and meal in ('เช้า','เย็น'));

create policy breakfast_update_public
  on public.breakfast_records for update
  to anon, authenticated
  using (true)
  with check (status = 'กิน' and meal in ('เช้า','เย็น'));


drop policy if exists breakfast_delete_public on public.breakfast_records;

create policy breakfast_delete_public
  on public.breakfast_records for delete
  to anon, authenticated
  using (true);
