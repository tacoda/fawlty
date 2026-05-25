<script>
  import { onMount } from "svelte";
  import { rooms } from "../api.js";

  let items = [];
  let error = "";
  let form = { number: "", room_type: "standard", floor: 1, nightly_rate_cents: 12000, status: "available" };

  const STATUSES = ["available", "occupied", "cleaning", "maintenance"];

  async function load() {
    try { items = await rooms.list(); error = ""; }
    catch (e) { error = e.message; }
  }

  async function create() {
    try {
      await rooms.create(form);
      form = { number: "", room_type: "standard", floor: 1, nightly_rate_cents: 12000, status: "available" };
      await load();
    } catch (e) { error = e.message; }
  }

  async function setStatus(room, status) {
    await rooms.update(room.id, { status });
    await load();
  }

  async function remove(room) {
    if (!confirm(`Delete room ${room.number}?`)) return;
    await rooms.remove(room.id);
    await load();
  }

  onMount(load);
</script>

<section class="card">
  <h2>Add room</h2>
  <form class="grid" on:submit|preventDefault={create}>
    <label>Number <input required bind:value={form.number} /></label>
    <label>Type
      <select bind:value={form.room_type}>
        <option>standard</option><option>deluxe</option><option>suite</option>
      </select>
    </label>
    <label>Floor <input type="number" bind:value={form.floor} /></label>
    <label>Rate (cents) <input type="number" bind:value={form.nightly_rate_cents} /></label>
    <label>Status
      <select bind:value={form.status}>
        {#each STATUSES as s}<option>{s}</option>{/each}
      </select>
    </label>
    <label>&nbsp;<button class="primary" type="submit">Create</button></label>
  </form>
  {#if error}<p class="error">{error}</p>{/if}
</section>

<section class="card">
  <h2>Rooms ({items.length})</h2>
  {#if items.length === 0}
    <div class="empty">No rooms yet.</div>
  {:else}
    <table>
      <thead><tr><th>#</th><th>Type</th><th>Floor</th><th>Rate</th><th>Status</th><th></th></tr></thead>
      <tbody>
        {#each items as r}
          <tr>
            <td><strong>{r.number}</strong></td>
            <td>{r.room_type}</td>
            <td>{r.floor ?? ""}</td>
            <td>${(r.nightly_rate_cents / 100).toFixed(2)}</td>
            <td>
              <select value={r.status} on:change={(e) => setStatus(r, e.target.value)}>
                {#each STATUSES as s}<option>{s}</option>{/each}
              </select>
              <span class="badge {r.status}">{r.status}</span>
            </td>
            <td class="row-actions">
              <button class="danger" on:click={() => remove(r)}>Delete</button>
            </td>
          </tr>
        {/each}
      </tbody>
    </table>
  {/if}
</section>
