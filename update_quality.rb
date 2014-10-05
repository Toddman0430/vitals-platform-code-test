require 'award'

def update_quality(awards)
  QualityUpdater.new.update(awards)
end

#Factored class out of updater functionality.

class QualityUpdater
  def update(awards)
    awards.each do |award|
      update_an(award)
    end
  end

  def update_an(award)
    updater_for(award).update(award)
  end

#Make sure we have plans to work with.

  def updater_for(award)
    pair = UPDATERS.find do |name, updater|
      name =~ award.name
    end
    updater = pair ? pair[1] : standard_updater
  end

  def standard_updater
    @standard_handler ||= BaseQualityUpdater.new
  end

#Inner base class for standard operations.

  class BaseQualityUpdater
    def update(award)
      update_quality(award)
      update_expires_in(award)
    end

    def update_quality(award)
      (award.expires_in <= 0) ? modify_quality(award, -2) : modify_quality(award, -1)
    end

    def update_expires_in(award)
      award.expires_in -= 1
    end

    def modify_quality(award, amount)
      award.quality += amount
      award.quality = 50 if award.quality > 50
      award.quality = 0 if award.quality < 0
    end
  end

  #Subclasses based on plan type.

  class BlueDistinctionPlusQualityUpdater < BaseQualityUpdater
    def update_quality(award)
    end
    def update_expires_in(award)
    end
  end

  class BlueFirstQualityUpdater < BaseQualityUpdater
    def update_quality(award)
      (award.expires_in <= 0) ? modify_quality(award, 2) : modify_quality(award, 1)
    end
  end

  class BlueCompareQualityUpdater < BaseQualityUpdater
    def update_quality(award)
      if award.expires_in > 10
        modify_quality(award, 1)
      elsif award.expires_in > 5
        modify_quality(award, 2)
      elsif award.expires_in > 0
        modify_quality(award, 3)
      else
        award.quality = 0
      end
    end
  end

  class BlueStarQualityUpdater < BaseQualityUpdater
    def update_quality(award)
      (award.expires_in <= 0) ? modify_quality(award, -4) : modify_quality(award, -2)
    end
  end

#'Configuration'. Instead of magic strings, use regexes to map plan type to quality logic.
  UPDATERS = [
      [/^Blue Distinction Plus$/, BlueDistinctionPlusQualityUpdater.new],
      [/^Blue First$/, BlueFirstQualityUpdater.new],
      [/^Blue Compare$/, BlueCompareQualityUpdater.new],
      [/^Blue Star$/, BlueStarQualityUpdater.new],
  ]


end
