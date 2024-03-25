require 'sinatra'
require 'slim'
require 'bcrypt'
require 'sqlite3'
require 'sinatra/reloader'

enable :sessions

$mutex = Mutex.new

def fetch_user_details(user_id)
  db = SQLite3::Database.new('db/users.db')
  db.results_as_hash = true
  user_details = db.execute("SELECT name, lastname FROM users WHERE user_id = ?", user_id).first
  user_details
end

def fetch_user_number(user_id)
  db = SQLite3::Database.new('db/users.db')
  db.results_as_hash = true
  user_number = db.execute("SELECT accountNumber FROM users WHERE user_id = ?", user_id).first
  user_number
end

def fetch_user_username(user_id)
  db = SQLite3::Database.new('db/users.db')
  db.results_as_hash = true
  user_username = db.execute("SELECT username FROM users WHERE user_id = ?", user_id).first
  user_username
end

def fetch_user_account_date(user_id)
  db = SQLite3::Database.new('db/users.db')
  db.results_as_hash = true
  account_date = db.execute("SELECT accountDate FROM users WHERE user_id = ?", user_id).first
  account_date
end

def fetch_user_account_cvv(user_id)
  db = SQLite3::Database.new('db/users.db')
  db.results_as_hash = true
  account_cvv = db.execute("SELECT cvv FROM users WHERE user_id = ?", user_id).first
  account_cvv
end

def fetch_latest_transactions(user_id)
  db = SQLite3::Database.new('db/users.db')
  db.results_as_hash = true
  db.execute("SELECT * FROM transactions WHERE user_id = ? ORDER BY created_at DESC LIMIT 5", user_id)
end

def format_balance(balance)
  sprintf('$%.2f', balance.to_f)
end

def format_balance_with_commas(balance)
  dollars, cents = balance.to_s.split('.')
  dollars_with_commas = dollars.chars.reverse.each_slice(3).map(&:join).join(',').reverse
  cents ||= '00'
  "$#{dollars_with_commas}.#{cents}"
end

def fetch_user_balance(user_id)
  db = SQLite3::Database.new('db/users.db')
  db.results_as_hash = true
  user_balance = db.execute("SELECT balance FROM users WHERE user_id = ?", user_id).first
  user_balance ? format_balance_with_commas(user_balance["balance"]) : format_balance_with_commas(0)
end

def generate_unique_account_number(db)
  loop do
    account_number = rand(100_000_000..999_999_999).to_s
    return account_number unless db.execute("SELECT COUNT(*) FROM users WHERE accountNumber = ?", account_number).first[0] > 0
  end
end

def generate_unique_account_date(db)
  loop do
    year = rand(25..31)
    month = rand(1..12)
    max_day = (month == 2 && Date.leap?(year)) ? 29 : 28
    max_day = 30 if [4, 6, 9, 11].include?(month)
    max_day = 31 if [1, 3, 5, 7, 8, 10, 12].include?(month)
    day = rand(1..max_day)
    account_date = "%02d%02d" % [year, month]
    return account_date unless db.execute("SELECT COUNT(*) FROM users WHERE accountDate = ?", account_date).first[0] > 0
  end
end

def generate_unique_account_cvv(db)
  loop do
    account_cvv = rand(100..999).to_s
    return account_cvv unless db.execute("SELECT COUNT(*) FROM users WHERE cvv = ?", account_cvv).first[0] > 0
  end
end

get '/' do
  slim :"webbInfo/start"
end

get '/signin' do
  slim :"userPages/signin"
end

post '/signin' do
  username = params[:username]
  email = params[:email]
  password = params[:password]

  db = SQLite3::Database.new('db/users.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM users WHERE username = ? OR email = ?", username, email).first
  password_hidden = result["password"]

  if BCrypt::Password.new(password_hidden) == password
    session[:id] = result["user_id"]
    redirect '/dashboard'
  else
    redirect '/wrongPassword'
  end
end

get '/dashboard' do
  user_id = session[:id]

  @user_details = fetch_user_details(user_id)
  @user_balance = fetch_user_balance(user_id)
  @user_username = fetch_user_username(user_id)
  @user_number = fetch_user_number(user_id)
  @account_cvv = fetch_user_account_date(user_id)
  @account_date = fetch_user_account_cvv(user_id)

  @latest_transactions = fetch_latest_transactions(user_id)

  @transfer_success = session.delete(:transfer_success)

  slim :"userPages/dashboard"
end

get '/signup' do
  slim :"userPages/signup"
end

post '/signup' do
  name = params[:name]
  lastname = params[:lastname]
  email = params[:email]
  username = params[:username]
  password = params[:password]
  password_confirm = params[:passwordConfirm]
  country = params[:country]

  db = SQLite3::Database.new('db/users.db')
  result = db.execute("SELECT COUNT(*) FROM users WHERE username = ? OR email = ?", username, email).first[0]

  if result > 0
    redirect('/wrongAccount')
  elsif password == password_confirm
    password_digest = BCrypt::Password.create(password)

    account_number = generate_unique_account_number(db)
    account_date = generate_unique_account_date(db)
    account_cvv = generate_unique_account_cvv(db)

    $mutex.synchronize do
      db.execute("INSERT INTO users (name, lastname, email, username, password, country, balance, accountNumber, accountDate, cvv) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", name, lastname, email, username, password_digest, country, 0, account_number, account_date, account_cvv)
    end

    redirect '/signin'
  else
    redirect '/wrongAccount'
  end
end

get '/accounts' do
  slim :"webbInfo/accounts"
end

get '/transactions' do
  slim :"webbInfo/transactions"
end

get '/onlineServices' do
  slim :"webbInfo/onlineServices"
end

get '/security' do
  slim :"webbInfo/security"
end

get '/wrongAccount' do
  slim :"errors/wrongAccount"
end

get '/wrongPassword' do
  slim :"errors/wrongPassword"
end

get '/wrongFunds' do
  slim :"errors/wrongFunds"
end

get '/failedTransfer' do
  slim :"errors/failedTransfer"
end

get '/successTransfer' do
  slim :"success/successTransfer"
end

get '/add' do
  slim :"moneyFlow/add"
end

post '/add_balance' do
  user_id = session[:id]
  amount = params[:amount].to_f

  db = SQLite3::Database.new('db/users.db')
  current_balance = db.execute("SELECT balance FROM users WHERE user_id = ?", user_id).first

  new_balance = current_balance[0] + amount

  db.execute("UPDATE users SET balance = ? WHERE user_id = ?", new_balance, user_id)

  redirect '/dashboard'
end

get '/sub' do
  slim :"moneyFlow/sub"
end

post '/sub_balance' do
  user_id = session[:id]
  amount = params[:amount].to_f

  db = SQLite3::Database.new('db/users.db')
  current_balance = db.execute("SELECT balance FROM users WHERE user_id = ?", user_id).first

  if amount > current_balance[0]
    redirect '/wrongFunds'
  else
    new_balance = current_balance[0] - amount
    db.execute("UPDATE users SET balance = ? WHERE user_id = ?", new_balance, user_id)
    redirect '/dashboard'
  end
end

get '/send' do
  slim :"moneyFlow/send"
end

post '/send_money' do
  sender_id = session[:id]
  receiver_account_number = params[:special_code]
  amount = params[:amount].to_f

  db = SQLite3::Database.new('db/users.db')

  sender_balance = db.execute("SELECT balance FROM users WHERE user_id = ?", sender_id).first[0]

  if amount > sender_balance
    redirect '/failedTransfer'
  else
    receiver_id = db.execute("SELECT user_id FROM users WHERE accountNumber = ?", receiver_account_number).first

    if receiver_id
      new_sender_balance = sender_balance - amount
      db.execute("UPDATE users SET balance = ? WHERE user_id = ?", new_sender_balance, sender_id)

      receiver_balance = db.execute("SELECT balance FROM users WHERE user_id = ?", receiver_id).first[0]
      new_receiver_balance = receiver_balance + amount
      db.execute("UPDATE users SET balance = ? WHERE user_id = ?", new_receiver_balance, receiver_id)

      # Record transaction
      db.execute("INSERT INTO transactions (user_id, amount, receiver_id, transaction_type) VALUES (?, ?, ?, 'send')", sender_id, amount, receiver_id)

      redirect '/successTransfer'
    else
      redirect '/failedTransfer'
    end
  end
end

get '/receive' do
  user_id = session[:id]

  @user_details = fetch_user_details(user_id)
  @user_balance = fetch_user_balance(user_id)
  @user_username = fetch_user_username(user_id)
  @user_number = fetch_user_number(user_id)
  @account_cvv = fetch_user_account_date(user_id)
  @account_date = fetch_user_account_cvv(user_id)

  slim :"moneyFlow/receive"
end

post '/receive_money' do
  user_id = session[:id]
  amount = params[:amount].to_f

  db = SQLite3::Database.new('db/users.db')

  current_balance = db.execute("SELECT balance FROM users WHERE user_id = ?", user_id).first[0]
  new_balance = current_balance + amount

  # Record transaction
  db.execute("INSERT INTO transactions (user_id, amount, transaction_type) VALUES (?, ?, 'receive')", user_id, amount)

  db.execute("UPDATE users SET balance = ? WHERE user_id = ?", new_balance, user_id)

  redirect '/dashboard'
end

get '/accountInfo' do
  user_id = session[:id]

  @user_details = fetch_user_details(user_id)
  @user_balance = fetch_user_balance(user_id)
  @user_username = fetch_user_username(user_id)
  @user_number = fetch_user_number(user_id)
  @account_date = fetch_user_account_date(user_id)
  @account_cvv = fetch_user_account_cvv(user_id)

  slim :"userPages/accountInfo"
end

post '/add_balance' do
  user_id = session[:id]
  amount = params[:amount].to_f

  db = SQLite3::Database.new('db/users.db')
  current_balance = db.execute("SELECT balance FROM users WHERE user_id = ?", user_id).first

  new_balance = current_balance[0] + amount

  # Record transaction
  db.execute("INSERT INTO transactions (user_id, amount, transaction_type) VALUES (?, ?, 'add')", user_id, amount)

  db.execute("UPDATE users SET balance = ? WHERE user_id = ?", new_balance, user_id)

  redirect '/dashboard'
end

post '/sub_balance' do
  user_id = session[:id]
  amount = params[:amount].to_f

  db = SQLite3::Database.new('db/users.db')
  current_balance = db.execute("SELECT balance FROM users WHERE user_id = ?", user_id).first

  if amount > current_balance[0]
    redirect '/wrongFunds'
  else
    new_balance = current_balance[0] - amount

    # Record transaction
    db.execute("INSERT INTO transactions (user_id, amount, transaction_type) VALUES (?, ?, 'sub')", user_id, amount)

    db.execute("UPDATE users SET balance = ? WHERE user_id = ?", new_balance, user_id)
    redirect '/dashboard'
  end
end

# Error handling
not_found do
  slim :not_found
end

error do
  slim :error
end
