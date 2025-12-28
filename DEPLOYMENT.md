# Clubbies Deployment Guide

This guide will walk you through deploying your Clubbies app to production using free hosting.

## Prerequisites

- GitHub account (to deploy from repository)
- Render.com account (for backend hosting) - free tier
- Cloudinary account (for photo storage) - free tier

## Part 1: Push to GitHub

1. Create a new repository on GitHub named "Clubbies"
2. Push your code:
```bash
cd /Users/jus/Development/GitHub/Clubbies
git add .
git commit -m "Prepare for deployment"
git branch -M master
git remote add origin https://github.com/YOUR_USERNAME/Clubbies.git
git push -u origin master
```

## Part 2: Set Up Cloudinary (Photo Storage)

Your uploaded photos currently save to a local `uploads/photos` folder. This won't work in production because most hosting platforms have ephemeral file systems (files are deleted on restart).

### Sign up for Cloudinary
1. Go to https://cloudinary.com/users/register/free
2. Sign up for free account
3. After signing in, go to Dashboard
4. Copy these values (you'll need them later):
   - Cloud Name
   - API Key
   - API Secret

### Install Cloudinary package
```bash
pip install cloudinary
```

### Update requirements.txt
Add this line to your requirements.txt:
```
cloudinary==1.41.0
```

### Update .env file
Add these to your `.env`:
```
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

## Part 3: Deploy Backend to Render.com

### Step 1: Create Render Account
1. Go to https://render.com
2. Sign up with GitHub (easier integration)

### Step 2: Create PostgreSQL Database
1. Click "New +" → "PostgreSQL"
2. Name: `clubbies-db`
3. Database: `clubbies`
4. User: `clubbies`
5. Region: Choose closest to you
6. Instance Type: **Free**
7. Click "Create Database"
8. Wait for it to provision (2-3 minutes)
9. **IMPORTANT**: Copy the "Internal Database URL" (starts with `postgresql://`)

### Step 3: Create Web Service
1. Click "New +" → "Web Service"
2. Connect your GitHub repository
3. Select "Clubbies" repository
4. Configure:
   - **Name**: `clubbies-api`
   - **Region**: Same as database
   - **Branch**: `master`
   - **Root Directory**: (leave empty)
   - **Runtime**: Python 3
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
   - **Instance Type**: **Free**

### Step 4: Add Environment Variables
In the "Environment" section, add:
- `DATABASE_URL`: Paste the Internal Database URL from Step 2
- `SECRET_KEY`: Generate new secret (use https://generate-secret.vercel.app/32 or any random string generator)
- `ALLOWED_HOSTS`: `*`
- `ENVIRONMENT`: `production`
- `MOBILE_DEV`: `false`
- `CLOUDINARY_CLOUD_NAME`: Your Cloudinary cloud name
- `CLOUDINARY_API_KEY`: Your Cloudinary API key
- `CLOUDINARY_API_SECRET`: Your Cloudinary API secret

### Step 5: Deploy
1. Click "Create Web Service"
2. Render will start building and deploying
3. Wait 5-10 minutes for first deployment
4. Once deployed, you'll see a URL like: `https://clubbies-api.onrender.com`
5. **Save this URL** - you'll need it for the mobile app!

### Step 6: Test Your API
Visit: `https://clubbies-api.onrender.com/health`
You should see: `{"status": "healthy"}`

## Part 4: Update Flutter App for Production

### Step 1: Update Environment Configuration
Edit `frontend/lib/config/environment.dart`:

Change line 14 to your Render URL:
```dart
static const String productionApiUrl = 'https://clubbies-api.onrender.com';
```

### Step 2: Switch to Production Mode
When you're ready to test with production backend:
1. In `frontend/lib/config/environment.dart`, change line 11:
```dart
static const bool isDevelopment = false;  // Changed from true
```

2. Hot restart your Flutter app (full restart, not hot reload)
3. Your app will now connect to the production backend!

### Step 3: Test Production Backend
1. Try registering a new account
2. Try logging in
3. Try browsing venues
4. Try uploading a photo (if you're admin)
5. Try rating a venue

### Step 4: Switch Back to Development
When developing locally, set it back:
```dart
static const bool isDevelopment = true;
```

## Part 5: Prepare for App Store

### Before Building for App Store:
1. Make sure `isDevelopment = false` in environment.dart
2. Remove all console.log/print statements (optional)
3. Test thoroughly with production backend
4. Build iOS release:
```bash
cd frontend
flutter build ios --release
```

## Important Notes

### Free Tier Limitations

**Render.com:**
- Backend sleeps after 15 minutes of inactivity
- First request after sleep takes 30-60 seconds to wake up
- Database expires after 90 days (you'll need to create a new one and migrate data)

**Cloudinary:**
- 25GB storage
- 25GB monthly bandwidth
- Should be plenty for early users!

### Cost to Upgrade (Optional)
If your app gets popular:
- Render Starter Plan: $7/month (no sleep, always fast)
- Render PostgreSQL: $7/month (never expires)
- Cloudinary Plus: $89/month (100GB storage)

### Monitoring
- Check Render dashboard for errors: https://dashboard.render.com
- Check Cloudinary usage: https://cloudinary.com/console

## Troubleshooting

### "Connection refused" errors in app
- Make sure `isDevelopment = false` in environment.dart
- Check that production URL is correct
- Verify Render service is running (not showing "Deploy failed")

### Photos not uploading
- Check Cloudinary credentials in Render environment variables
- Make sure user is admin (check database or API response)
- Check Render logs for errors

### Database connection errors
- Verify DATABASE_URL in Render matches PostgreSQL Internal URL
- Check if database is running in Render dashboard

### Backend returns 500 errors
- Check Render logs: Dashboard → Your Service → Logs tab
- Look for Python errors or stack traces

## Next Steps

Once deployed successfully:
1. Populate your database with real venue data
2. Create your admin account
3. Upload venue photos
4. Invite beta testers
5. Prepare for App Store submission!

## Support

For deployment issues:
- Render Docs: https://render.com/docs
- Cloudinary Docs: https://cloudinary.com/documentation
- FastAPI Docs: https://fastapi.tiangolo.com

Good luck with your launch! 🚀
