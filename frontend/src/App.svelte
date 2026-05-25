<script>
  import Rooms from "./views/Rooms.svelte";
  import Guests from "./views/Guests.svelte";
  import Reservations from "./views/Reservations.svelte";
  import Stays from "./views/Stays.svelte";

  const tabs = [
    { id: "rooms",        label: "Rooms",        comp: Rooms },
    { id: "guests",       label: "Guests",       comp: Guests },
    { id: "reservations", label: "Reservations", comp: Reservations },
    { id: "stays",        label: "Stays",        comp: Stays }
  ];
  let active = "rooms";
  $: ActiveComp = tabs.find((t) => t.id === active).comp;
</script>

<header class="app">
  <h1>FAWLTY · Hotel Operations</h1>
  <nav>
    {#each tabs as t}
      <button class:active={active === t.id} on:click={() => (active = t.id)}>{t.label}</button>
    {/each}
  </nav>
</header>

<main>
  <svelte:component this={ActiveComp} />
</main>
