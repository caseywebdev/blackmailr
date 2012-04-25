# By using the symbol ':user', we get Factory Girl to simulate the User model.
Factory.define :user do |user|
  user.email                 "mhartl@example.com"
  user.password              "foobar"
  user.password_confirmation "foobar"
end

Factory.define :blackmail do |blackmail|
  blackmail.title             "I saw that!"
  blackmail.description       "I saw you in the park, you KNOW what I'm talking about! I will tell everyone if you don't meet my demands."
  blackmail.victim_name       "Burt Renolds"
  blackmail.victim_email      "bettleBoy@hotmail.com"
  blackmail.expired_at        "2012-06-31 22:18:00"
  blackmail.association :user
end

Factory.define :demand do |demand|
  demand.description          "I want $5,000 by expire time"
  demand.completed            "false"
  demand.association :blackmail
end