<script>
  import { onMount } from "svelte";
  import { reservations, guests, rooms } from "../api.js";

  let items = [];
  let guestList = [];
  let roomList = [];        // every room, so the table can name one by id
  let freeRooms = [];       // only what the form's dates allow
  let roomsLoading = false;
  let roomsError = "";
  let latestCheck = 0;      // a slow reply for old dates must not win
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
    // Booking, cancelling, or checking in all change what is free tonight.
    await checkAvailability(form.check_in_date, form.check_out_date);
  }

  $: checkAvailability(form.check_in_date, form.check_out_date);

  async function checkAvailability(checkIn, checkOut) {
    const token = ++latestCheck;
    freeRooms = [];
    roomsError = "";
    if (!checkIn || !checkOut) { roomsLoading = false; return; }
    if (checkOut <= checkIn) {
      roomsLoading = false;
      roomsError = "Check-out must be after check-in.";
      return;
    }
    roomsLoading = true;
    try {
      const free = await rooms.available(checkIn, checkOut);
      if (token !== latestCheck) return;
      freeRooms = free;
      if (form.room_id && !free.some((r) => r.id === Number(form.room_id))) form.room_id = "";
    } catch (e) {
      if (token !== latestCheck) return;
      roomsError = e.message;
    } finally {
      if (token === latestCheck) roomsLoading = false;
    }
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
    try {
      await reservations.update(r.id, { status: "cancelled" });
      error = "";
      await load();
    } catch (e) { error = e.message; }
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

<style>
  .hint { color: var(--muted); font-size: 0.85rem; }
</style>

<section class="card">
  <h2>New reservation</h2>
  <form class="grid" on:submit|preventDefault={create}>
    <label>Guest
      <select required bind:value={form.guest_id}>
        <option value="" disabled>Select…</option>
        {#each guestList as g}<option value={g.id}>{g.last_name}, {g.first_name}</option>{/each}
      </select>
    </label>
    <label>Check-in  <input type="date" required bind:value={form.check_in_date} /></label>
    <label>Check-out <input type="date" required bind:value={form.check_out_date} /></label>
    <label>Room
      <select required bind:value={form.room_id} disabled={roomsLoading || freeRooms.length === 0}>
        <option value="" disabled>
          {roomsLoading ? "Checking…" : freeRooms.length ? "Select…" : "None free"}
        </option>
        {#each freeRooms as r}<option value={r.id}>{r.number} · {r.room_type}</option>{/each}
      </select>
    </label>
    <label>Notes     <input bind:value={form.notes} /></label>
    <label>&nbsp;<button class="primary" type="submit" disabled={roomsLoading}>Book</button></label>
  </form>
  {#if roomsError}
    <p class="error">{roomsError}</p>
  {:else if roomsLoading}
    <p class="hint">Checking which rooms are free…</p>
  {:else if freeRooms.length === 0}
    <p class="hint">No rooms are free for those dates.</p>
  {:else}
    <p class="hint">{freeRooms.length} room{freeRooms.length === 1 ? "" : "s"} free for those dates.</p>
  {/if}
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
