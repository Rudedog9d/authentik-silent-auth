<script lang="ts">
    import {createClient, userStore} from "$lib/auth.js";
    import {onMount} from "svelte";

    let client;

    onMount(async () => {
        client = await createClient();
        console.log(client);
    })

    export async function loginWithRedirect(): Promise<void> {
        await client.signinRedirect({
            redirect_uri: window.location.href,
        });
    }
</script>

<p>
  This page will attempt to login on first load using the
  <a href="https://authts.github.io/oidc-client-ts/classes/UserManager.html#signinSilent">
    <code>UserManger.signinSilent</code>
  </a>
  method from <code>oidc-client-ts</code>.
</p>

<p>
  You may also press the login button to attempt a signin via
  <a href="https://authts.github.io/oidc-client-ts/classes/UserManager.html#signinRedirect">
    <code>UserManger.signinRedirect</code>
  </a>
</p>

<p>
  {#if !$userStore}
    <button on:click={loginWithRedirect}>Login</button>
  {:else}
    <h1>User:</h1>
    <pre>{JSON.stringify($userStore, null, 2)}</pre>
  {/if}
</p>
