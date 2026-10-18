# Lab 4: Login and Registration Form

A login and registration system built with static HTML pages, JavaScript, and PHP/MySQL.
The pages are plain `.html` files. PHP is used only for the database work and always replies with JSON.

## Requirements

- XAMPP (Apache + MySQL + PHP), started from XAMPP or with `sudo /opt/lampp/lampp start`
- The `registration` database and `user` table from the lab:

```sql
CREATE DATABASE registration;
USE registration;

CREATE TABLE user(
    user_id INT NOT NULL AUTO_INCREMENT,
    email VARCHAR(225) NOT NULL,
    name VARCHAR(225) NOT NULL,
    password VARCHAR(225) NOT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id)
);
```

## File overview

| File              | Type         | Role                                                            |
| ----------------- | ------------ | --------------------------------------------------------------- |
| `index.html`      | Page         | Login form                                                      |
| `register.html`   | Page         | Registration form                                               |
| `welcome.html`    | Page         | Shows "Welcome {Name}" after a successful login or registration |
| `script.js`       | Browser JS   | Validation, Ajax calls, welcome message                         |
| `style.css`       | Styles       | Layout and look of all three pages                              |
| `db.php`          | PHP          | Starts the session, connects to MySQL, defines `json_out()`     |
| `login.php`       | PHP endpoint | Checks email and password against the database                  |
| `register.php`    | PHP endpoint | Validates and inserts a new user                                |
| `check_email.php` | PHP endpoint | Says whether an email is already registered                     |
| `session.php`     | PHP endpoint | Returns the logged-in user's name; handles logout               |

## How the pieces work together

```
Browser (HTML + script.js)  --fetch()-->  PHP endpoint  -->  MySQL
                            <--- JSON ---
```

1. The user fills in a form.
2. `script.js` validates the input in the browser. If anything is wrong, it shows the messages on the same page and stops.
3. If the input is valid, `script.js` sends the form data to the matching PHP file with `fetch()` (Ajax).
4. The PHP file validates again, runs the SQL query, and returns JSON.
5. `script.js` reads the JSON: on `success` it goes to `welcome.html`, otherwise it displays the `errors` list.

## The code, file by file

### `db.php`

Included by every endpoint except `session.php`, which only reads the session.

- `session_start()` enables `$_SESSION`, which remembers who is logged in.
- `header('Content-Type: application/json')` makes every response JSON.
- `json_out($data)` prints the data as JSON and stops the script.
- `mysqli_report(MYSQLI_REPORT_OFF)` makes MySQL errors return a value instead of crashing PHP with a bare 500 error. If the connection fails, the script returns a readable JSON error such as "Database connection failed: ...".
- `$conn` is the connection object used by the other files.

### `login.php`

1. Reads `email` and `password` from the POST data.
2. Server-side validation: the email must not be empty and must be a valid format (`filter_var`), and the password must not be empty.
3. Hashes the password with `md5()` and runs:
   `SELECT user_id, name FROM user WHERE email = ? AND password = ?`
4. If a row is found, it stores `user_id` and `name` in the session and returns `{"success": true}`.
5. Otherwise it returns `"Incorrect email or password."`

### `register.php`

1. Reads `name`, `email`, `password`, `confirm_password`.
2. Validates: every field non-empty, email format valid, and both passwords identical.
3. Checks uniqueness with `SELECT 1 FROM user WHERE email = ?`. If a row exists, it returns **"Email Already Exists"**.
4. Inserts the user with `INSERT INTO user (email, name, password) VALUES (?, ?, ?)`, with the password stored as `md5(...)`. The `user_id` and `registration_date` columns fill themselves in (auto increment and default timestamp).
5. Saves the new user's `user_id` and `name` in the session and returns `{"success": true}`, so a new user is logged in right after registering.

### `check_email.php`

Takes `?email=...` and returns `{"exists": true}` or `{"exists": false}`. The registration page calls it when the user leaves the email field and again on submit, so the "Email Already Exists" message does not need a full form submission.

### `session.php`

- Normal call: returns `{"loggedIn": true, "name": "..."}` if the session holds a user, otherwise `{"loggedIn": false}`.
- `?logout=1`: destroys the session.

### `script.js`

One script is shared by all three pages. Each section runs only if its page's elements exist.

- **Helpers:** `showErrors(list)` fills the red message box (`#messages`) and hides it when the list is empty. `emailPattern` is the regex for a valid email. `submitAjax(form)` posts the form with `fetch()` and handles the JSON reply.
- **Login section** (`#loginForm`): checks that the email and password are not empty and that the email format is valid.
- **Registration section** (`#registerForm`):
  - Names each empty field ("Name is empty.", "Email is empty.", and so on).
  - Checks the email format.
  - Checks that the password and confirmation match.
  - Calls `check_email.php` to enforce a unique email.
- **Welcome section** (`#welcomeText`): asks `session.php` who is logged in and writes "Welcome {Name}". If nobody is logged in, it redirects to `index.html`. The Log out link calls `session.php?logout=1`.

The name is inserted with `textContent` instead of `innerHTML`, so a name containing HTML is displayed as text and never executed.

### `style.css`

Centers a white card on a light background and styles the labels, inputs, button, and the red error box. It also contains the focus outline for the inputs.

## Lab requirements and where they are implemented

| Requirement                                                   | Where                                          |
| ------------------------------------------------------------- | ---------------------------------------------- |
| Login asks for email and password, not empty (JS)             | `script.js`, login section                     |
| PHP selects the user by email and password                    | `login.php`                                    |
| Registration asks for name, email, password, confirm password | `register.html`                                |
| Show which field is empty                                     | `script.js`, registration section              |
| Email must be unique, show "Email Already Exists"             | `check_email.php`, `register.php`, `script.js` |
| Password and confirm password must match                      | `script.js` and `register.php`                 |
| PHP inserts a new record into `user`                          | `register.php`                                 |
| Valid input shows **Welcome {Name}**                          | `welcome.html` + `session.php`                 |
| Invalid input shows a message describing the errors           | `showErrors()` in `script.js`                  |
| Bonus: valid email format                                     | `script.js` (regex) and PHP (`filter_var`)     |
| Bonus: MD5 password                                           | `md5()` in `login.php` and `register.php`      |
| Bonus: CSS                                                    | `style.css`                                    |
| Bonus: Ajax submission                                        | `fetch()` in `script.js`                       |

## Design notes

- **Validation happens twice.** The JavaScript checks give instant feedback, but they can be bypassed, so PHP repeats the same checks before touching the database.
- **Prepared statements** (`prepare`, `bind_param`, `execute`) keep user input separate from the SQL, which prevents SQL injection.
- **MD5** is used because the lab asks for it. It is not safe for real applications. A real project would use `password_hash()` for storing and `password_verify()` for checking, and a unique index on `email` in the table.
- **Uniqueness is checked in PHP, not by a database constraint.** Two simultaneous registrations with the same email could in theory both succeed. Adding `ALTER TABLE user ADD UNIQUE (email);` closes that gap.
