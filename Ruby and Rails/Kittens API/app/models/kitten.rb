class Kitten < ApplicationRecord
  validates :name, presence: { message: "is required! A kitten cannot wander the universe nameless." },
                   length: { maximum: 50, message: "is too long! Keep the kitten name under 50 characters." }

  validates :age, presence: { message: "must be provided." },
                  numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 35,
                                  message: "must be an integer between 0 and 35. Kittens aren't immortal vampires!" }

  validates :cuteness, presence: { message: "must be rated." },
                       numericality: { only_integer: true, in: 1..10,
                                       message: "must be between 1 and 10 (though let's face it, all kittens deserve a 10)." }

  validates :softness, presence: { message: "must be rated on the floof scale." },
                       numericality: { only_integer: true, in: 1..10,
                                       message: "must be on a floof scale of 1 to 10." }

  # Human-readable floof level description
  def softness_label
    case softness
    when 1..3 then "Crisp & Wiry"
    when 4..6 then "Silky Smooth"
    when 7..8 then "Ultra Velvety"
    when 9..10 then "Cloud-Level Floof"
    else "Soft"
    end
  end

  # Human-readable cuteness rank
  def cuteness_label
    case cuteness
    when 1..4 then "Modestly Cute"
    when 5..7 then "Dangerously Charming"
    when 8..9 then "Heart-Melting"
    when 10 then "Maximum Overdose of Cute"
    else "Cute"
    end
  end

  # Default JSON serialization formatting for clean REST API responses
  def as_json(options = nil)
    super({
      only: [:id, :name, :age, :cuteness, :softness, :created_at, :updated_at],
      methods: [:softness_label, :cuteness_label]
    }.merge(options || {}))
  end
end
