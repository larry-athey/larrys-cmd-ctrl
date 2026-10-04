# Enabling HTTP Basic Authentication in Lighttpd

> **Disclaimer:** **Larry's Cmd-Ctrl** is designed and intended for **isolated local network or loopback deployment only**. It does not include native user authentication mechanisms. If you choose to port-forward or expose your server to the internet or an untrusted network, **you do so at your own risk**. 

This guide provides step-by-step instructions for locking down your web root (including phpMyAdmin and administration tools) using Lighttpd's built-in `mod_auth` module and `.htpasswd` basic authentication.

---

## Step 1: Install `apache2-utils` (for `htpasswd`)

Lighttpd uses standard `.htpasswd` files generated using the `htpasswd` utility (provided by Apache tools).

- **Debian / Ubuntu / Raspberry Pi OS:**
  ```bash
  sudo apt-get update
  sudo apt-get install apache2-utils
  ```
- **Arch Linux:**
  ```bash
  sudo pacman -S apache-tools
  ```
- **Fedora / RHEL:**
  ```bash
  sudo dnf install httpd-tools
  ```

---

## Step 2: Create the `.htpasswd` Credentials File

Create a protected password file outside of your public web root so it cannot be downloaded over HTTP.

1. Create a directory for your server passwords:
   ```bash
   sudo mkdir -p /etc/lighttpd/passwords
   ```

2. Create the `.htpasswd` file and add an admin user (replace `admin` with your desired username):
   ```bash
   sudo htpasswd -c /etc/lighttpd/passwords/.htpasswd admin
   ```
   *You will be prompted to enter and confirm a password.*

3. Set secure permissions on the password file so only Lighttpd can read it:
   ```bash
   sudo chown -R www-data:www-data /etc/lighttpd/passwords
   sudo chmod 600 /etc/lighttpd/passwords/.htpasswd
   ```

*(To add additional users later, run `sudo htpasswd /etc/lighttpd/passwords/.htpasswd <username>` without the `-c` flag).*

---

## Step 3: Configure Lighttpd (`lighttpd.conf`)

Next, enable the authentication module and apply the lock to your entire web root.

1. Open your Lighttpd configuration file:
   ```bash
   sudo nano /etc/lighttpd/lighttpd.conf
   ```

2. Ensure `mod_auth` and `mod_authn_file` are included in `server.modules`:
   ```lighttpd
   server.modules += (
       "mod_auth",
       "mod_authn_file"
   )
   ```
   *(On Debian/Ubuntu systems, you can also enable this module via `sudo lighty-enable-mod auth` followed by `sudo service lighttpd force-reload`).*

3. Add the authentication rules at the end of `lighttpd.conf` to protect the root directory (`/`):

   ```lighttpd
   # Set authentication backend to htpasswd file
   auth.backend = "htpasswd"
   auth.backend.htpasswd.userfile = "/etc/lighttpd/passwords/.htpasswd"

   # Protect the entire root path and all subdirectories (including phpMyAdmin)
   auth.require = ( "" =>
       (
           "method"  => "basic",
           "realm"   => "Restricted Access - Cmd-Ctrl",
           "require" => "valid-user"
       )
   )
   ```

---

## Step 4: Test and Restart Lighttpd

1. Test your Lighttpd configuration for syntax errors:
   ```bash
   sudo lighttpd -t -f /etc/lighttpd/lighttpd.conf
   ```
   *If it returns `Syntax OK`, proceed to the next step.*

2. Restart the Lighttpd service to apply changes:
   ```bash
   sudo systemctl restart lighttpd
   ```

---

## Step 5: Verify the Lockdown

1. Open your browser and navigate to your application URL or IP address (e.g., `http://localhost:63888/` or `http://<your-ip>:63888/phpmyadmin`).
2. A native browser popup should request your credentials.
3. Access will be denied (`401 Unauthorized`) unless valid credentials from your `.htpasswd` file are supplied.

---

### Important Security Note on Basic Authentication

When using HTTP Basic Authentication without HTTPS, credentials are sent encoded in Base64 over the network. If exposed over the internet, consider running Lighttpd behind a reverse proxy (like Nginx, Caddy, or Cloudflare Tunnels) with an SSL/TLS certificate (HTTPS) enabled.