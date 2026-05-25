<script>
  import { onMount } from "svelte";
  import { guests } from "../api.js";

  let items = [];
  let error = "";
  let form = { first_name: "", last_name: "", email: "", phone: "", address: "" };

  async function load() {
    try { items = await guests.list(); error = ""; }
    catch (e) { error = e.message; }
  }

  async function create() {
    try {
      await guests.create(form);
      form = { first_name: "", last_name: "", email: "", phone: "", address: "" };
      await load();
    } catch (e) { error = e.message; }
  }

  async function remove(g) {
    if (!confirm(`Delete guest ${g.first_name} ${g.last_name}?`)) return;
    await guests.remove(g.id);
    await load();
  }

  onMount(load);
</script>

<section class="card">
  <h2>Add guest</h2>
  <form class="grid" on:submit|preventDefault={create}>
    <label>First name <input required bind:value={form.first_name} /></label>
    <label>Last name  <input required bind:value={form.last_name} /></label>
    <label>Email      <input type="email" bind:value={form.email} /></label>
    <label>Phone      <input bind:value={form.phone} /></label>
    <label>Address    <input bind:value={form.address} /></label>
    <label>&nbsp;<button class="primary" type="submit">Create</button></label>
  </form>
  {#if error}<p class="error">{error}</p>{/if}
</section>

<section class="card">
  <h2>Guests ({items.length})</h2>
  {#if items.length === 0}
    <div class="empty">No guests yet.</div>
  {:else}
    <table>
      <thead><tr><th>Name</th><th>Email</th><th>Phone</th><th></th></tr></thead>
      <tbody>
        {#each items as g}
          <tr>
            <td><strong>{g.last_name}, {g.first_name}</strong></td>
            <td>{g.email ?? ""}</td>
            <td>{g.phone ?? ""}</td>
            <td class="row-actions">
              <button class="danger" on:click={() => remove(g)}>Delete</button>
            </td>
          </tr>
        {/each}
      </tbody>
    </table>
  {/if}
</section>
