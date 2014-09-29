require 'award'

def update_quality(awards)
  awards.each do |award|
    initial_quality = award.quality
    name = award.name
    compute_with_blue_first_and_compare(award)
    award.expires_in -= 1   unless blue_distinction_plus?(name)
    factor_in_expiration_dates(award)
    quality_decrease = initial_quality - award.quality
    award.quality -= quality_decrease if blue_star?(name) && quality_decrease >= 1
  end
end

def compute_with_blue_first_and_compare(award)
  if (!blue_first?(award.name) && !blue_compare?(award.name))
    (award.quality -= 1 unless blue_distinction_plus?(award.name) if award.quality > 0)
  else
    if quality_ceiling?(award.quality)
      award.quality += 1
      if blue_compare?(award.name)
          award.quality += 1 if award.expires_in < 11 if quality_ceiling?(award.quality)
          award.quality += 1 if award.expires_in < 6 if quality_ceiling?(award.quality)
      end
    end
  end
end

def factor_in_expiration_dates(award)
  if (!blue_first?(award.name))
    (!blue_compare?(award.name)) ?
        award.quality -= 1 unless blue_distinction_plus?(award.name) if award.quality > 0 :
        award.quality = award.quality - award.quality
  else
    award.quality += 1
  end if quality_ceiling?(award.quality) if award.expires_in < 0
end

def quality_ceiling?(quality)
  quality < 50
end

def blue_compare?(name)
  name == 'Blue Compare'
end

def blue_distinction_plus?(name)
  name == 'Blue Distinction Plus'
end

def blue_star?(name)
  name == 'Blue Star'
end

def blue_first?(name)
  name == 'Blue First'
end