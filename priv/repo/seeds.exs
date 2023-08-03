# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Chat.Repo.insert!(%Chat.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

users = [
  %{
    email: "paul@gmail.com",
    password: "123456789012",
    first_name: "Paul",
    last_name: "Otieno",
    phone_number: "072312321"
  },
  %{
    email: "ken@gmail.com",
    password: "123456789012",
    first_name: "Ken",
    last_name: "Otieno",
    phone_number: "072312322"
  },
  %{
    email: "jane@gmail.com",
    password: "123456789012",
    first_name: "Jane",
    last_name: "Otieno",
    phone_number: "072312323"
  },
  %{
    email: "pete@gmail.com",
    password: "123456789012",
    first_name: "Pete",
    last_name: "Otieno",
    phone_number: "072312324"
  },
  %{
    email: "carol@gmail.com",
    password: "123456789012",
    first_name: "Carol",
    last_name: "Otieno",
    phone_number: "072312325"
  }
]

for user <- users do
  {user_params, profile_params} = Map.split(user, [:email, :password])

  {:ok, user} = Chat.Accounts.register_user(user_params)

  profile_params = Map.put(profile_params, :user_id, user.id)
  {:ok, profile} = Chat.Accounts.create_profile(profile_params)
end
