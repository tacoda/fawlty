<script>
  import { onMount } from "svelte";
  import { stays, guests, rooms } from "../api.js";

  let items = [];
  let guestList = [];
  let roomList = [];
  let activeOnly = true;
  let error = "";

  async function load() {
    try {
      [items, guestList, roomList] = await Promise.all([
        stays.list(activeOnly), guests.list(), rooms.list()
      ]);
      error = "";
    } catch (e) { error = e.message; }
  }

  async function checkOut(s) {
    if (!confirm("Check out this guest?")) return;
    try { await stays.checkOut(s.id); await load(); }
    catch (e) { error = e.message; }
  }

  function guestName(id) {
    const g = guestList.find((x) => x.id === id);
    return g ? `${g.first_name} ${g.last_name}` : `#${id}`;
  }
  function roomNumber(id) {
    const r = roomList.find((x) => x.id === id);
    return r ? r.number : `#${id}`;
  }
  function fmt(t) { return t ? new Date(t).toLocaleString() : "—"; }

  $: activeOnly, load();

  onMount(load);
</script>

<section class="card">
  <h2>Stays</h2>
  <label style="flex-direction:row; align-items:center; gap:0.5rem;">
    <input type="checkbox" bind:checked={activeOnly} /> Active only
  </label>
  {#if error}<p class="error">{error}</p>{/if}
</section>

<section class="card">
  {#if items.length === 0}
    <div class="empty">No stays.</div>
  {:else}
    <table>
      <thead><tr><th>Guest</th><th>Room</th><th>Checked in</th><th>Checked out</th><th></th></tr></thead>
      <tbody>
        {#each items as s}
          <tr>
            <td>{guestName(s.guest_id)}</td>
            <td>{roomNumber(s.room_id)}</td>
            <td>{fmt(s.checked_in_at)}</td>
            <td>{fmt(s.checked_out_at)}</td>
            <td class="row-actions">
              {#if !s.checked_out_at}
                <button class="primary" on:click={() => checkOut(s)}>Check out</button>
              {/if}
            </td>
          </tr>
        {/each}
      </tbody>
    </table>
  {/if}
</section>
