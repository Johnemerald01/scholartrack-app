-- Sample data for development only. All entries are fictional.
insert into public.scholarships
  (title, provider, description, min_cgpa, amount, currency, deadline, level, field_of_study, countries, apply_url)
values
  ('Sample Merit Award', 'Example Foundation', 'Fictional entry for UI testing.', 3.00, 1000, 'USD', current_date + 60, 'Undergraduate', null, '{}', 'https://example.com/apply'),
  ('Sample STEM Scholarship', 'Example STEM Trust', 'Fictional entry for UI testing.', 3.50, 2500, 'USD', current_date + 90, 'Undergraduate', 'Engineering', '{}', 'https://example.com/stem'),
  ('Sample Excellence Grant', 'Example Education Fund', 'Fictional entry for UI testing.', 4.00, 5000, 'USD', current_date + 45, 'Postgraduate', null, '{}', 'https://example.com/excellence'),
  ('Sample Leadership Bursary', 'Example Leaders Society', 'Fictional entry for UI testing.', 4.50, 8000, 'USD', current_date + 120, null, null, '{}', 'https://example.com/leadership');
