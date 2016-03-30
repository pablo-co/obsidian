sys.out 'Estimating the value of PI...'
num = 4.0
pi = 0
plus = true

den = 1
while den < 100
  added = num / den
  added *= -1 unless plus
  pi += added
  den += 2
  plus = !plus
  sys.out "PI ~= #{pi}"
end

sys.out '---- Final guess ----'
sys.out "PI ~= #{pi}"
sys.out "Error = #{(Math::PI - pi) / Math::PI * 100.0}%"