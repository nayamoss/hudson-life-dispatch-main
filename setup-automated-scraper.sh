#!/bin/bash

# Automated Scraper Setup Script
# This sets up the scraper to run completely automatically

cd "$(dirname "$0")/hudson-life-dispatch-backend"

echo "🚀 Setting Up Automated Scraper System..."
echo ""

# 1. Check if cron is available
if ! command -v crontab &> /dev/null; then
    echo "❌ crontab not found. Installing..."
    # On macOS, cron should be available by default
fi

# 2. Add Laravel scheduler to crontab
echo "📅 Setting up Laravel Scheduler..."
(crontab -l 2>/dev/null | grep -v "artisan schedule:run"; echo "* * * * * cd $(pwd) && php artisan schedule:run >> /dev/null 2>&1") | crontab -

echo "✅ Laravel Scheduler added to crontab"
echo ""

# 3. Check supervisor
if command -v supervisorctl &> /dev/null; then
    echo "🔧 Supervisor detected. Setting up queue workers..."
    
    # Copy supervisor config
    SUPERVISOR_CONF_DIR="/opt/homebrew/etc/supervisor.d"
    if [ -d "$SUPERVISOR_CONF_DIR" ]; then
        cp ../supervisor-scraper-queue.conf "$SUPERVISOR_CONF_DIR/"
        supervisorctl reread
        supervisorctl update
        supervisorctl start hudson-scraper-queue:*
        echo "✅ Queue workers started via Supervisor"
    else
        echo "⚠️  Supervisor config directory not found"
        echo "    Manual setup: Copy supervisor-scraper-queue.conf to your supervisor directory"
    fi
else
    echo "⚠️  Supervisor not installed. Installing via Homebrew..."
    if command -v brew &> /dev/null; then
        brew install supervisor
        brew services start supervisor
        echo "✅ Supervisor installed and started"
        
        # Try setup again
        SUPERVISOR_CONF_DIR="/opt/homebrew/etc/supervisor.d"
        if [ -d "$SUPERVISOR_CONF_DIR" ]; then
            cp ../supervisor-scraper-queue.conf "$SUPERVISOR_CONF_DIR/"
            supervisorctl reread
            supervisorctl update
            supervisorctl start hudson-scraper-queue:*
            echo "✅ Queue workers started"
        fi
    else
        echo "❌ Homebrew not found. Please install supervisor manually:"
        echo "   brew install supervisor"
        echo "   brew services start supervisor"
    fi
fi

echo ""
echo "🎉 Automation Setup Complete!"
echo ""
echo "📊 What's Running Automatically:"
echo "  • Hourly scraping (6am-10pm): Top 100 high-priority resources"
echo "  • Daily scraping (3am): 50 additional resources"
echo "  • Weekly ranking (Sunday 2am): Recalculate all priorities"
echo "  • Queue workers: 2 background workers processing jobs"
echo ""
echo "📋 Verify Setup:"
echo "  crontab -l                          # Check scheduler"
echo "  supervisorctl status                # Check queue workers"
echo "  php artisan scrape:status           # View scraping stats"
echo "  tail -f storage/logs/scraper.log    # Watch scraper logs"
echo ""
echo "🔧 Manual Controls (if needed):"
echo "  supervisorctl restart hudson-scraper-queue:*  # Restart workers"
echo "  php artisan queue:restart                     # Restart queue"
echo ""

