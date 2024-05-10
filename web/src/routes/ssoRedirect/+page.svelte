<script>
  import { browser } from '$app/environment';
  // if not in a browser, this will cause an error (during pre-rendering/sso)
  if (browser) parent.postMessage(location.href, location.origin);
  console.log('This is a ssoRedirect page', browser, browser && location.href, browser && location.origin);
</script>
