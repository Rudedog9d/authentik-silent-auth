import {
    Log,
    type SigninSilentArgs,
    type SignoutSilentArgs,
    User,
    UserManager,
    type UserProfile,
} from 'oidc-client-ts';
import type {Writable} from "svelte/store";
import {get, writable} from "svelte/store";

export const clientStore: Writable<UserManager> = writable();
export const userStore: Writable<User | void | null> = writable();

export async function createClient(){
    if (get(clientStore)) {
        console.debug('oidcClient already exists'); // this happens in the dev server during hot-reloads
        return get(clientStore);
    }
    const client = new UserManager({
        authority: "https://localhost/application/o/scoreboard-ui",
        client_id: "scoreboard-ui",
        redirect_uri: window.location.origin,
        silent_redirect_uri: window.origin + '/ssoRedirect',
        silentRequestTimeoutInSeconds: 4,
        response_type: 'code',
        scope: 'openid',

        response_mode: 'query',
        filterProtocolClaims: true,
    });

    try {
        if (window.location.search.includes('state=')) {
            const user = (await client.signinCallback(window.location.search)) || null;
            userStore.set(user);
            console.log('user logged in', user) // this is the success state
            // clear search from URL - we intentionally call this after signinCallback
            // so we have the original url in the browser if signinCallback throws an error
            window.location.search = '';
        }
    } catch (e) {
        console.error('init failed');
        console.error(e);
    }

    Log.setLogger({
        debug: console.debug,
        info: console.info,
        warn: console.warn,
        error: console.error,
    });
    Log.setLevel(Log.DEBUG);

    try {
        console.log('[createClient] try silent auth');
        await client.signinSilent();
    } catch (err) {
        console.error('signinSilent failed', err);
    }

    return client;
}
