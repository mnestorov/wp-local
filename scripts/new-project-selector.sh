#!/usr/bin/env bash
set -e

echo "🚀  Local Development Environment Setup"
echo "   Choose your project type:"
echo ""
echo "   1) WordPress Project"
echo "   2) Laravel Project"
echo ""

while true; do
    read -rp "Enter your choice (1 or 2): " choice
    case $choice in
        1)
            echo "📝  Setting up WordPress project..."
            ./scripts/new-wordpress-project.sh
            break
            ;;
        2)
            echo "🎯  Setting up Laravel project..."
            ./scripts/new-laravel-project.sh
            break
            ;;
        *)
            echo "❌  Invalid choice. Please enter 1 for WordPress or 2 for Laravel."
            ;;
    esac
done