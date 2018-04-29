SELECT
  id::text,
  fgdc_symbol,
  color::text,
  symbol_color::text
FROM mapping.unit
WHERE fgdc_symbol IS NOT NULL
