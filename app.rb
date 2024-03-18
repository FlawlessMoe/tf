require 'slim'
require 'byebug'
require 'bcrypt'
require 'sqlite3'
require 'sinatra'
require 'sinatra/reloader'
require_relative './model.rb'

$mutex = Mutex.new

# -----------------------------------

get('/') do
  slim(:start)
end

get('/signin') do
  slim(:signin)
end

get('/dashboard') do
  slim(:dashboard)
end

get('/signup') do
  slim(:signup)
end

get('/accounts') do
  slim(:accounts)
end

get('/transactions') do
  slim(:transactions)
end

get('/onlineServices') do
  slim(:onlineServices)
end

get('/security') do
  slim(:security)
end

# -----------------------------------

post("/signup") do
  name = params[:name]
  lastname = params[:lastname]
  email = params[:email]
  username = params[:username]
  password = params[:password]
  passwordConfirm = params[:passwordConfirm]
  country = params[:country]

  if (password == passwordConfirm)
    password_digest = BCrypt::Password.create(password)

    $mutex.synchronize do
      # Use a mutex lock to prevent concurrent access to the database
      db = SQLite3::Database.new('db/users.db')

      # Insert into users table
      db.execute("INSERT INTO users (name, lastname, email, username, password, country) VALUES(?,?,?,?,?,?)", name, lastname, email, username, password_digest, country)

      # Get the user_id of the newly inserted user
      user_id = db.last_insert_row_id

      # Generate a random 6-digit account number
      account_number = rand(100_000..999_999)

      # Insert into bankAccounts table
      db.execute("INSERT INTO bankAccounts (userID, accountNumber, balance) VALUES(?,?,0)", user_id, account_number)
    end

    redirect('/')
  else
    redirect('/signup')
  end
end

post('/signin') do
  username = params[:username]
  email = params[:email]
  password = params[:password]
  db = SQLite3::Database.new('db/users.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM users WHERE username  =? OR email=? ",username,email).first

  if result != nil
    pwdigest= result["password"]
    id= result["id"]
    if BCrypt::Password.new(pwdigest) == password
      session[:id] = id
      redirect('/dashboard')
    end

  else
    "fel lösenord"
  end
  if BCrypt::Password.new(pwdigest) == password
    session[:id] = id
    redirect('/')
  else
    "fel lösenord"
  end
end
# -----------------------------------
