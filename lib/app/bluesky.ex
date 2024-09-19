defmodule App.Bluesky do
  @posts_url "https://public.api.bsky.app/xrpc/app.bsky.feed.getPosts?uris[]="
  def get_posts(uris) do
    url = @posts_url <> "#{uris}"
    Req.get(url)
  end
end
