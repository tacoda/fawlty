<script>
  import { onMount } from "svelte";
  import { reservations, guests, rooms } from "../api.js";

  let items = [];
  let guestList = [];
  let roomList = [];
  let error = "";
  let form = newForm();

  function newForm() {
    const today = new Date().toISOString().slice(0, 10);
    const tomorrow = new Date(Date.now() + 86400000).toISOString().slice(0, 10);
    return { guest_id: "", room_id: "", check_in_date: today, check_out_date: tomorrow, notes: "" };
  }

  async function load() {
    try {
      [items, guestList, roomList] = await Promise.all([
        reservations.list(), guests.list(), rooms.list()
      ]);
      error = "";
    } catch (e) { error = e.message; }
  }

  async function create() {
    try {
      await reservations.create({
        ...form,
        guest_id: Number(form.guest_id),
        room_id: Number(form.room_id)
      });
      form = newForm();
      await load();
    } catch (e) { error = e.message; }
  }

  async function checkIn(r) {
    try { await reservations.checkIn(r.id); await load(); }
    catch (e) { error = e.message; }
  }

  async function cancel(r) {
    if (!confirm("Cancel this reservation?")) return;
    await reservations.update(r.id, { status: "cancelled" });
    await load();
  }

  async function remove(r) {
    if (!confirm("Delete reservation?")) return;
    await reservations.remove(r.id);
    await load();
  }

  function guestName(id) {
    const g = guestList.find((x) => x.id === id);
    return g ? `${g.first_name} ${g.last_name}` : `#${id}`;
  }
  function roomNumber(id) {
    const r = roomList.find((x) => x.id === id);
    return r ? r.number : `#${id}`;
  }

  onMount(load);
</script>

<section class="card">
  <h2>New reservation</h2>
  <form class="grid" on:submit|preventDefault={create}>
    <label>Guest
      <select required bind:value={form.guest_id}>
        <option value="" disabled>Select…</option>
        {#each guestList as g}<option value={g.id}>{g.last_name}, {g.first_name}</option>{/each}
      </select>
    </label>
    <label>Room
      <select required bind:value={form.room_id}>
        <option value="" disabled>Select…</option>
        {#each roomList as r}<option value={r.id}>{r.number} · {r.room_type}</option>{/each}
      </select>
    </label>
    <label>Check-in  <input type="date" required bind:value={form.check_in_date} /></label>
    <label>Check-out <input type="date" required bind:value={form.check_out_date} /></label>
    <label>Notes     <input bind:value={form.notes} /></label>
    <label>&nbsp;<button class="primary" type="submit">Book</button></label>
  </form>
  {#if error}<p class="error">{error}</p>{/if}
</section>

<section class="card">
  <h2>Reservations ({items.length})</h2>
  {#if items.length === 0}
    <div class="empty">No reservations yet.</div>
  {:else}
    <table>
      <thead><tr><th>Guest</th><th>Room</th><th>Dates</th><th>Status</th><th></th></tr></thead>
      <tbody>
        {#each items as r}
          <tr>
            <td>{guestName(r.guest_id)}</td>
            <td>{roomNumber(r.room_id)}</td>
            <td>{r.check_in_date} → {r.check_out_date}</td>
            <td><span class="badge {r.status}">{r.status}</span></td>
            <td class="row-actions">
              {#if r.status === "booked"}
                <button class="primary" on:click={() => checkIn(r)}>Check in</button>
                <button on:click={() => cancel(r)}>Cancel</button>
              {/if}
              <button class="danger" on:click={() => remove(r)}>Delete</button>
            </td>
          </tr>
        {/each}
      </tbody>
    </table>
  {/if}
</section>
