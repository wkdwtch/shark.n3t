import os
import requests
from bs4 import BeautifulSoup

# Replace with the target Blogger URL
BLOG_URL = "https://sharkn3t.blogspot.com"
OUTPUT_DIR = "blogger_posts"

# Create output directory
if not os.path.exists(OUTPUT_DIR):
    os.makedirs(OUTPUT_DIR)

def scrape_blogger():
    # Fetch the main page
    response = requests.get(https://sharkn3t.blogspot.com)
    soup = BeautifulSoup(response.text, 'html.parser')

    # Find all post links (Blogger's standard CSS class for post titles)
    post_elements = soup.select('h3.post-title a')
    
    if not post_elements:
        print("No posts found. Please check the CSS selector for the post titles.")
        return

    for index, post in enumerate(post_elements):
        title = post.text.strip()
        link = post['href']
        
        print(f"Scraping: {title}")
        
        try:
            # Fetch the individual post
            post_response = requests.get(link)
            post_soup = BeautifulSoup(post_response.text, 'html.parser')
            
            # Extract content (Blogger's standard CSS class for post bodies)
            content_div = post_soup.select_one('div.post-body')
            
            if content_div:
                post_text = content_div.text.strip()
                
                # Create a safe filename
                safe_title = "".join(c for c in title if c.isalnum() or c in (' ', '_', '-')).rstrip()
                filename = os.path.join(OUTPUT_DIR, f"{safe_title}.txt")
                
                # Save to file directory
                with open(filename, 'w', encoding='utf-8') as f:
                    f.write(f"Title: {title}\n")
                    f.write(f"URL: {link}\n")
                    f.write("-" * 40 + "\n")
                    f.write(post_text)
                print(f"Saved: {filename}")
        except Exception as e:
            print(f"Failed to scrape {link}: {e}")

if __name__ == "__main__":
    scrape_blogger()
