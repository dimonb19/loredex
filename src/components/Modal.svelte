<script lang="ts">
  import getImage from "../utils/image.ts";
  import { getColor } from "../utils/color.ts";
  import characters from "../data/characters.ts";
  import { stories } from "../data/timeline.ts";
  import { type Character } from "../lib/types";
  import {
    showModal,
    selectedCharacter,
    fullscreenPicture,
  } from "../stores/modal.ts";
  import { timeSystem, timeNotes, sagaSummary } from "../data/timeline.ts";
  import { getSeasonName } from "../stores/season.ts";
  import Story from "./Story.svelte";

  let width: number;

  let activeTab: "connections" | "stories" = "stories";
  const activeTabStyling =
    "color: #010020; text-shadow: 0 0 0.1vw #010020; background-color: rgba(51, 226, 230, 0.75); box-shadow: 0 0.5vw 0.5vw #010020;";

  let previousCharacters: Character[] = [];

  let dialog: HTMLDialogElement;
  let showHistory: boolean = false;
  let historySection: HTMLElement | null;

  $: if (historySection && showHistory) {
    const sectionCords = historySection.getBoundingClientRect();
    dialog.scroll({
      top: sectionCords.y - 100,
      behavior: "smooth",
    });
  }

  $: if (dialog && $showModal) {
    dialog.showModal();
  } else if (!$showModal) {
    closeDialog();
    if (showHistory) showHistory = false;
  }

  const closeDialog = () => {
    $showModal = null;
    $selectedCharacter = null;
    if (previousCharacters.length > 0) previousCharacters = [];
    dialog?.close();
  };

  const handleSelectCharacter = (name: string) => {
    previousCharacters.push($selectedCharacter!);
    characters.map((character) => {
      if (name === character.name) $selectedCharacter = character;
    });
    if (showHistory) showHistory = false;
  };

  function handleBackArrow() {
    if (previousCharacters.length === 0) {
      closeDialog();
      return;
    } else {
      $selectedCharacter = previousCharacters.pop()!;
      if (showHistory) showHistory = false;
    }
  }

  const showFullscreenPicture = (event: any) => {
    if (width < 600) return;
    const target = event.target as HTMLImageElement;
    $fullscreenPicture = target.src;
  };

  let showEpisodes: boolean = false;
  let showSummary: boolean = false;

  // SVG Icons
  let closeSvgFocus: boolean = false;
  let backArrowSvgFocus: boolean = false;
  let deathSvgFocus: boolean = false;
  let locationSvgFocus: boolean = false;
</script>

<svelte:window bind:innerWidth={width} />

<!-- svelte-ignore a11y-click-events-have-key-events
  a11y-no-noninteractive-element-interactions
  a11y-no-static-element-interactions -->
<dialog
  class="blur"
  bind:this={dialog}
  on:close={closeDialog}
  on:click|self={closeDialog}
>
  {#if $fullscreenPicture && width > 600}
    <div
      class="fullscreen-picture"
      role="button"
      tabindex="0"
      on:click={() => ($fullscreenPicture = null)}
    >
      <img src={$fullscreenPicture} alt="Character" />
    </div>
  {/if}

  <main
    on:click|stopPropagation
    style="display: {$fullscreenPicture ? 'none' : 'block'}"
  >
    <header>
      <button
        class="back-arrow"
        on:click={handleBackArrow}
        on:pointerover={() => (backArrowSvgFocus = true)}
        on:pointerout={() => (backArrowSvgFocus = false)}
        aria-label="Back"
      >
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="-100 -100 200 200">
          <defs>
            <mask id="quit-svg-mask">
              <circle r="95" fill="white" />
              <path
                class="quit-svg-mask"
                d="
                  M 50 0
                  L -50 0
                  L 0 -50
                  M -50 0
                  L 0 50
                "
                fill="none"
                stroke="black"
                stroke-width="25"
                stroke-linecap="round"
                stroke-linejoin="round"
                transform={backArrowSvgFocus ? "scale(1.2)" : ""}
              />
            </mask>
          </defs>

          <circle
            style="
              transition: all 0.3s ease-in-out;
              transform: {backArrowSvgFocus ? 'scale(1.05);' : 'none'}
              fill: {backArrowSvgFocus
              ? 'rgb(51, 226, 230)'
              : 'rgba(51, 226, 230, 0.75)'}
            "
            fill="rgba(51, 226, 230, 0.75)"
            r="95"
            mask="url(#quit-svg-mask)"
          />
        </svg>
      </button>
      <div class="title">
        {#if $selectedCharacter}
          {#if $selectedCharacter.dead && width > 600}
            <svg
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 512 512"
              class="death-svg"
              fill={deathSvgFocus ? getColor($selectedCharacter.name) : "none"}
              stroke={getColor($selectedCharacter.name)}
              stroke-width="24"
              opacity="0.75"
              on:pointerover={() => (deathSvgFocus = true)}
              on:pointerout={() => (deathSvgFocus = false)}
            >
              <path
                d="M246.53 21.03c-62.334.34-123.514 15.678-165 39.44l-6.155 2.06c19.528 58.267 48.163 98.687 80.938 132.376l-1.72 67.47 64.5 30.437c-19 58.985-34.515 128.892-50.405 197.656h191.125c-10.308-47.13-20.516-94.494-32.157-138.72 23.774 28.113 46.51 61.63 67.063 104.313l16.842-8.094c-22.568-46.87-47.938-83.34-74.312-113.626l31.125-24.28-47.47-104.377 48.22-33.75c-18.963-35.457-37.446-71.306-72.28-92.656-32.51 19.993-52 56.712-72.22 92.5l-29.22 34.69c-28.89-25.67-54.975-53.34-76.093-90.532C192.195 60.42 315.858 47.172 419.656 72.56 373.43 35.602 309.392 20.69 246.53 21.032z"
              />
            </svg>
          {:else if $selectedCharacter.location && width > 600}
            <svg
              xmlns="http://www.w3.org/2000/svg"
              viewBox="-100 -100 200 200"
              class="location-svg"
              fill="rgb(51, 226, 230)"
              stroke="rgb(51, 226, 230)"
              stroke-width="7.5"
              stroke-linejoin="round"
              stroke-linecap="round"
              opacity="0.75"
              on:pointerover={() => (locationSvgFocus = true)}
              on:pointerout={() => (locationSvgFocus = false)}
            >
              <defs>
                <mask id="location-inner-ellipse">
                  <ellipse
                    cx="0"
                    cy="62"
                    rx="70"
                    ry="25"
                    fill="white"
                    stroke="white"
                  />
                  <ellipse
                    cx="0"
                    cy="57"
                    rx="57.5"
                    ry="15"
                    fill="black"
                    stroke="black"
                    stroke-width="2.5"
                  />
                  <g fill="black" stroke="black" stroke-width="25">
                    <circle r="50" cx="0" cy="-37.5" />
                    <polygon
                      points="
                        0 60 -45 -15.5 45 -15.5
                      "
                    />
                  </g>
                </mask>

                <mask id="location-inner-circle">
                  <g fill="white" stroke="white">
                    <circle r="50" cx="0" cy="-37.5" />
                    <polygon
                      points="
                        0 60 -45 -15.5 45 -15.5
                      "
                    />
                  </g>
                  <circle
                    r="25"
                    cx="0"
                    cy="-37.5"
                    fill="black"
                    stroke="black"
                  />
                </mask>
              </defs>

              <ellipse
                cx="0"
                cy="62"
                rx="70"
                ry="25"
                mask="url(#location-inner-ellipse)"
                style={locationSvgFocus
                  ? "transform: scale(1.1) translateY(-5%)"
                  : ""}
              />
              <g
                mask="url(#location-inner-circle)"
                style={locationSvgFocus ? "transform: translateY(5%)" : ""}
              >
                <circle r="50" cx="0" cy="-37.5" />
                <polygon
                  points="
                    0 60 -45 -15.5 45 -15.5
                  "
                />
              </g>
            </svg>
          {/if}
          <h1
            style={$selectedCharacter.location
              ? ""
              : `color: ${getColor($selectedCharacter.name, 0.75)}`}
          >
            {$selectedCharacter.name}
          </h1>
        {:else}
          <h1>The Dischordian Saga</h1>
        {/if}
      </div>
      <button
        class="close-button"
        on:click={closeDialog}
        on:pointerover={() => (closeSvgFocus = true)}
        on:pointerout={() => (closeSvgFocus = false)}
        aria-label="Close"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="-100 -100 200 200"
          class="close-svg"
          stroke="rgba(255, 60, 64, 0.85)"
          stroke-width="30"
          stroke-linecap="round"
          style="
            transform: {closeSvgFocus ? 'scale(1.2);' : 'none'}
            stroke: {closeSvgFocus
            ? 'rgb(255, 60, 64)'
            : 'rgba(255, 60, 64, 0.85)'}
          "
        >
          <path
            d="
              M -65 -65
              L 65 65
              M -65 65
              L 65 -65
            "
            fill="none"
          />
        </svg>
      </button>
    </header>

    <!-- CHARACTER WINDOW -->
    {#if $showModal === "character" && $selectedCharacter}
      {#key $selectedCharacter}
        <section class="character-window">
          <section
            class="general-info"
            style={$selectedCharacter.potentialNFT
              ? "justify-content: space-between;"
              : ""}
          >
            <div class="image-container">
              <img
                src={$selectedCharacter.picture}
                alt={$selectedCharacter.name}
                width="1024"
                height="1024"
                on:click={showFullscreenPicture}
                style={$selectedCharacter.history
                  ? "border-bottom-left-radius: 0;border-bottom-right-radius: 0;"
                  : ""}
              />
              {#if $selectedCharacter.history}
                <button
                  on:click={() => {
                    showHistory = !showHistory;
                  }}>{showHistory ? "Hide" : "Show"} history</button
                >
              {/if}
            </div>

            <article
              style={$selectedCharacter.potentialNFT
                ? "align-items: center; text-align: center;"
                : ""}
            >
              <div
                class="status"
                style={$selectedCharacter.potentialNFT
                  ? "align-items: center"
                  : ""}
              >
                <span>
                  <p>Affiliation:</p>
                  <strong>{$selectedCharacter.affiliation}</strong>
                </span>
                <span>
                  <p>Status:</p>
                  <strong>{@html $selectedCharacter.status}</strong>
                </span>
              </div>
              <p>{@html $selectedCharacter.bio}</p>
            </article>

            <!-- NFT picture -->
            {#if $selectedCharacter.potentialNFT}
              <div class="image-container">
                <img
                  src="https://api.degenerousdao.com/nft/image/{$selectedCharacter.potentialNFT}"
                  alt="Potential #{$selectedCharacter.potentialNFT}"
                  on:click={showFullscreenPicture}
                  width="1024"
                  height="1024"
                />
                <div>
                  <a
                    class="opensea"
                    href="https://opensea.io/assets/ethereum/0xfa511d5c4cce10321e6e86793cc083213c36278e/{$selectedCharacter.potentialNFT}"
                    target="_blank"
                  >
                    <img src="/opensea.png" alt="OpenSea" draggable="false" />
                  </a>
                  <a
                    class="magiceden"
                    href="https://magiceden.io/collections/ethereum/0xfa511d5c4cce10321e6e86793cc083213c36278e?search=%22%23{$selectedCharacter.potentialNFT}%22"
                    target="_blank"
                  >
                    <img
                      src="/magic-eden.png"
                      alt="Magic Eden"
                      draggable="false"
                    />
                  </a>
                </div>
              </div>
            {/if}
          </section>

          <!-- CONEXUS games -->
          {#if $selectedCharacter.stories}
            {#each $selectedCharacter.stories as storySection}
              {#if storySection.season == 99}
                <div class="play-button">
                  <p>PLAY NOW</p>
                  <div>
                    {#each storySection.episodes as episode}
                      <button
                        on:click={() =>
                          window.open(
                            "https://conexus.ink/",
                            "_blank"
                          )}>{episode}</button
                      >
                    {/each}
                  </div>
                  <img src="/conexus.avif" alt="CoNexus" />
                </div>
              {/if}
            {/each}
          {/if}

          <!-- Character VIDEO -->
          {#if $selectedCharacter.video}
            <iframe
              src={`https://www.youtube.com/embed/${$selectedCharacter.video}`}
              class="character-video"
              title="YouTube"
              allowfullscreen
            ></iframe>
          {/if}

          <!-- Character HISTORY -->
          {#if showHistory && $selectedCharacter.history}
            <article class="history" bind:this={historySection}>
              <hr />
              {@html $selectedCharacter.history}
              <hr />
            </article>
          {/if}

          <!-- Character TRANSFORMATIONS -->
          {#if $selectedCharacter.transformations}
            <section class="transformation">
              {#each $selectedCharacter.transformations as { name, picture }, index}
                <div>
                  <img
                    src={picture}
                    alt={name}
                    width="1024"
                    height="1024"
                    on:click={showFullscreenPicture}
                  />
                  <p>{name}</p>
                </div>
                {#if index !== $selectedCharacter.transformations.length - 1}
                  <span>→</span>
                {/if}
              {/each}
            </section>
          {/if}

          <!-- CONNECTIONS & APPEARANCES TABS -->
          <section class="tabs-wrapper">
            <div class="tabs-container">
              <button
                class="tab"
                style={activeTab === "connections" ? activeTabStyling : ""}
                on:click={() => {
                  activeTab = "connections";
                }}
              >
                Connections
                {#if width > 600}
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    viewBox="-100 -100 200 200"
                    class="chain-svg connections-icon"
                    fill="rgb(51, 226, 230)"
                    stroke="rgb(51, 226, 230)"
                    stroke-width="12"
                    stroke-linejoin="round"
                    stroke-linecap="round"
                    opacity={activeTab === "connections" ? "1" : "0.25"}
                    transform={activeTab === "connections" ? "scale(1.35)" : ""}
                  >
                    <defs>
                      <mask id="chain-connection">
                        <rect
                          x="-85"
                          y="-35"
                          width="100"
                          height="60"
                          rx="25"
                          fill="none"
                          stroke="white"
                          mask="url(#chain-connection)"
                        />
                        <line
                          x1="0"
                          y1="20"
                          x2="10"
                          y2="30"
                          stroke-width={activeTab === "connections"
                            ? "0"
                            : "50"}
                          stroke="black"
                          transform="rotate(45)"
                        />
                      </mask>
                    </defs>

                    <rect
                      id="chain-svg-rect"
                      x="-85"
                      y="-35"
                      width="100"
                      height="60"
                      rx="25"
                      fill="none"
                      transform="rotate(-45)"
                      mask="url(#chain-connection)"
                    />
                    <use
                      href="#chain-svg-rect"
                      transform="rotate(180) translate(-5 -5)"
                    />
                  </svg>
                {/if}
              </button>
              <button
                class="tab"
                style={activeTab === "stories" ? activeTabStyling : ""}
                on:click={() => {
                  activeTab = "stories";
                }}
              >
                Appearances
                {#if width > 600}
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    viewBox="-100 -100 200 200"
                    class="play-svg stories-icon"
                    fill="none"
                    stroke="rgb(51, 226, 230)"
                    stroke-width="15"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    opacity={activeTab === "stories" ? "1" : "0.25"}
                    transform={activeTab === "stories" ? "scale(1.25)" : ""}
                  >
                    <polygon
                      points="
                        -26 -36 -26 36 36 0
                      "
                      fill="rgb(51, 226, 230)"
                      transform={activeTab === "stories" ? "scale(1.1)" : ""}
                    />
                    <circle r="90" />
                  </svg>
                {/if}
              </button>
            </div>

            <section class="tab-section">
              <!-- Character CONNECTIONS -->
              <div
                class="connected-characters"
                style="display: {activeTab === 'connections' ? 'flex' : 'none'}"
              >
                {#if $selectedCharacter.connections}
                  {#if $selectedCharacter.connections.allies}
                    <h2 style="background-color: rgba(0, 185, 55, 0.25)">
                      Allied characters
                    </h2>
                    <div class="characters-section">
                      {#each $selectedCharacter.connections.allies as ally}
                        <div
                          on:click={() => handleSelectCharacter(ally)}
                          style="border-color: {getColor(ally, 0.9)}"
                        >
                          <img
                            src={getImage(ally)}
                            alt={ally}
                            width="1024"
                            height="1024"
                          />
                          <p>
                            {ally}
                          </p>
                        </div>
                      {/each}
                    </div>
                  {/if}
                  {#if $selectedCharacter.connections.enemies}
                    <h2 style="background-color: rgba(255, 60, 64, 0.25)">
                      Enemy characters
                    </h2>
                    <div class="characters-section">
                      {#each $selectedCharacter.connections.enemies as enemy}
                        <div
                          on:click={() => handleSelectCharacter(enemy)}
                          style="border-color: {getColor(enemy, 0.9)}"
                        >
                          <img
                            src={getImage(enemy)}
                            alt={enemy}
                            width="1024"
                            height="1024"
                          />
                          <p>
                            {enemy}
                          </p>
                        </div>
                      {/each}
                    </div>
                  {/if}
                  {#if $selectedCharacter.connections.neutral}
                    <h2 style="background-color: rgba(150, 150, 150, 0.25)">
                      Neutral characters
                    </h2>
                    <div class="characters-section">
                      {#each $selectedCharacter.connections.neutral as neutral}
                        <div
                          on:click={() => handleSelectCharacter(neutral)}
                          style="border-color: {getColor(neutral, 0.9)}"
                        >
                          <img
                            src={getImage(neutral)}
                            alt={neutral}
                            width="1024"
                            height="1024"
                          />
                          <p>
                            {neutral}
                          </p>
                        </div>
                      {/each}
                    </div>
                  {/if}
                  {#if $selectedCharacter.connections.locations}
                    <h2 style="background-color: rgb(22, 30, 95)">Locations</h2>
                    <div class="characters-section">
                      {#each $selectedCharacter.connections.locations as location}
                        <div
                          on:click={() => handleSelectCharacter(location)}
                          style="
                              border-color: {getColor(location, 0.9)};
                              background-color: rgb(22, 30, 95);
                            "
                        >
                          <img
                            src={getImage(location)}
                            alt={location}
                            width="1024"
                            height="1024"
                          />
                          <p>
                            {location}
                          </p>
                        </div>
                      {/each}
                    </div>
                  {/if}
                {:else}
                  <p
                    class="empty-note"
                    style="display: {activeTab === 'connections'
                      ? 'flex'
                      : 'none'}"
                  >
                    No connected characters.
                  </p>
                {/if}
              </div>
              <!-- Character APPEARANCES -->
              <div
                class="stories"
                style="display: {activeTab === 'stories' ? 'flex' : 'none'}"
              >
                {#if $selectedCharacter.stories}
                  {#each $selectedCharacter.stories as season}
                    <h2>{getSeasonName(season.season)}</h2>
                    {#each season.episodes as episodeTitle}
                      {#each stories as storySection}
                        {#if storySection.season == season.season}
                          {#each storySection.episodes as episodeObject}
                            {#if episodeObject.title == episodeTitle}
                              <Story {episodeObject} />
                            {/if}
                          {/each}
                        {/if}
                      {/each}
                    {/each}
                  {/each}
                {:else}
                  <p
                    class="empty-note"
                    style="display: {activeTab === 'stories' ? 'flex' : 'none'}"
                  >
                    No appearances in stories.
                  </p>
                {/if}
              </div>
            </section>
          </section>
        </section>
      {/key}
      <!-- GENERAL TIMELINE SECTION -->
    {:else if $showModal === "timeline"}
      <section class="dischordian-saga">
        <h1 class="timeline-title">Comprehensive Timeline of the A.A. Era</h1>

        <div class="month-system">
          <p>{@html timeSystem.note}</p>
          <ol>
            {#each timeSystem.months as month}
              <li>{@html month}</li>
            {/each}
          </ol>
        </div>

        <section class="wrapper">
          <button
            class="opener"
            style={showSummary
              ? "border-bottom-right-radius: 0; border-bottom-left-radius: 0;"
              : ""}
            on:click={() => (showSummary = !showSummary)}
            >{showSummary ? "Hide" : "Show"} Summary&nbsp;
            <span>(SPOILERS)</span>
            <svg
              xmlns="http://www.w3.org/2000/svg"
              viewBox="-100 -100 200 200"
              class="warning-svg"
              fill="rgb(255, 60, 64)"
              stroke="rgb(255, 60, 64)"
              stroke-width="5"
              stroke-linejoin="round"
              stroke-linecap="round"
              transform={showSummary ? "scale(1.25)" : ""}
            >
              <polygon
                points="0 -80 90 75 -90 75"
                fill="none"
                stroke-width="12"
                transform={showSummary ? "scale(0)" : ""}
              />
              <g transform={showSummary ? "scale(1.5)" : ""}>
                <circle r="12" cy="-20" />
                <path
                  d="
                    M -12 -20
                    L -6 25
                    L 6 25
                    L 12 -20
                    Z
                  "
                />
                <circle r="6" cy="25" />
                <circle r="8" cy="50" />
              </g>
            </svg>
          </button>
          {#if showSummary}
            <div class="timeline-container">
              {@html sagaSummary}
            </div>
          {/if}
        </section>

        <section class="wrapper">
          <button
            class="opener"
            style={showEpisodes
              ? "border-bottom-right-radius: 0; border-bottom-left-radius: 0;"
              : ""}
            on:click={() => (showEpisodes = !showEpisodes)}
            >{showEpisodes ? "Hide" : "Show"} Story Nodes</button
          >
          {#if showEpisodes}
            <div class="timeline-container">
              <div class="episodes">
                {#each stories as storySection}
                  {#if storySection.season !== 99}
                    <h2 class={storySection.season == 99 ? "empty-note" : ""}>
                      {getSeasonName(storySection.season)}
                    </h2>
                    {#each storySection.episodes as episodeObject}
                      <Story {episodeObject} />
                    {/each}
                  {/if}
                {/each}
              </div>
            </div>
          {/if}
        </section>

        <article class="history">
          <hr />
          {@html timeNotes}
          <hr />
        </article>
      </section>
    {/if}
  </main>
</dialog>

<style lang="scss">
  .fullscreen-picture {
    z-index: 1000;
    width: 100%;
    height: 90vh;
    position: fixed;
    top: 0;
    left: 0;
    display: flex;
    justify-content: center;
    align-items: center;
    cursor: zoom-out;
    animation: fade 0.5s ease-in-out forwards;

    img {
      height: 90vh;
      width: auto;
      border-left: 0.05vw solid rgba(51, 226, 230, 0.25);
      border-right: 0.05vw solid rgba(51, 226, 230, 0.25);
    }
  }

  .timeline-title {
    text-align: center;
    font-size: 2.5vw;
    line-height: 2.5vw;
    color: rgba(51, 226, 230, 0.75);
  }

  dialog {
    width: 90vw;
    height: 90vh;
    border: none;
    color: inherit;
    background-color: rgba(1, 0, 32, 0.75);
    box-shadow: 0 0 0.5vw rgba(51, 226, 230, 0.5);
    border-radius: 2vw;
    overflow-y: scroll;
    cursor: default;

    .character-window {
      display: flex;
      flex-flow: column nowrap;
      justify-content: center;
      align-items: center;
      gap: 2vw;
      animation: fade 0.5s ease-in-out forwards;
    }

    main {
      img {
        cursor: pointer;
        transition: all 0.3s ease-in-out;
      }

      header {
        z-index: 100;
        position: sticky;
        top: 0;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 1vw;
        background-color: rgba(1, 0, 32, 0.9);
        border-top-left-radius: 2vw;
        border-top-right-radius: 2vw;

        div {
          display: flex;
          justify-content: center;
          align-items: center;
          gap: 1vw;

          svg {
            width: 3vw;
            height: 3vw;
          }

          h1 {
            text-align: center;
            font-size: 2.5vw;
            line-height: 2vw;
            color: rgba(51, 226, 230, 0.75);
          }
        }

        .close-button,
        .back-arrow {
          padding: 0.5vw;

          svg {
            width: 3vw;
            height: 3vw;
          }
        }
      }

      .general-info {
        width: 95%;
        padding: 1vw;
        background-color: rgba(51, 226, 230, 0.1);
        box-shadow: inset 0 0 0.5vw rgba(51, 226, 230, 0.25);
        border-radius: 1vw;
        display: flex;
        flex-flow: row nowrap;
        align-items: center;
        justify-content: flex-start;
        gap: 2vw;

        .image-container {
          display: flex;
          flex-flow: column nowrap;
          align-items: center;
          width: 15vw;
          min-width: 15vw;
          box-shadow: 0 0 0.5vw #010020;
          border-radius: 0.5vw;

          img {
            z-index: 1;
            width: inherit;
            height: 15vw;
            object-fit: cover;
            border-radius: inherit;
            background-color: #010020;
            cursor: zoom-in;
          }

          button {
            width: inherit;
            border: none;
            border-radius: 0;
            border-bottom-left-radius: 0.5vw;
            border-bottom-right-radius: 0.5vw;
            font-size: 1.25vw;
            color: rgba(51, 226, 230, 0.9);
            background-color: rgba(51, 226, 230, 0.25);

            &:hover,
            &:active {
              transform: none;
              color: #010020;
              background-color: rgba(51, 226, 230, 0.75);
            }
          }

          div {
            width: inherit;
            display: flex;
            flex-flow: row nowrap;
            height: 3vw;

            .opensea {
              border-bottom-left-radius: 0.5vw;
            }

            .magiceden {
              border-bottom-right-radius: 0.5vw;
            }

            a {
              width: 7.5vw;
              height: auto;
              display: flex;
              flex-flow: row nowrap;
              justify-content: center;
              align-items: center;
              background-color: rgba(1, 0, 32, 0.5);

              img {
                z-index: 0;
                width: auto;
                height: 2vw;
                background-color: transparent;
                opacity: 0.9;
                cursor: inherit;
                filter: drop-shadow(0 0 0.5vw rgba(1, 0, 32, 0.5));
              }

              &:hover,
              &:active {
                background-color: rgba(51, 226, 230, 0.25);
              }
            }
          }
        }

        article {
          min-height: 17.5vw;
          display: flex;
          flex-flow: column nowrap;
          justify-content: space-around;
          align-items: flex-start;
          gap: 1vw;
          font-size: 1vw;
          color: rgba(51, 226, 230, 0.75);

          .status {
            display: flex;
            flex-flow: column nowrap;
            gap: 1vw;
            font-size: 1.35vw;
            color: rgba(51, 226, 230, 0.65);

            span {
              display: flex;
              flex-flow: row nowrap;
              align-items: center;
              gap: 1vw;

              strong {
                color: rgba(51, 226, 230, 0.75);
              }
            }
          }
        }
      }

      .play-button {
        width: 95%;
        display: flex;
        flex-flow: row nowrap;
        justify-content: space-around;
        align-items: center;
        padding: 0.5vw 2vw;
        gap: 2vw;
        font-size: 2vw;
        color: #010020;
        background-color: rgba(51, 226, 230, 0.5);
        box-shadow: inset 0 0 0.5vw #010020;
        border-radius: 1vw;

        p {
          text-align: right;
          text-shadow: 0 0 0.1vw #010020;
          width: 12.5vw;
          white-space: nowrap;
        }

        div {
          display: flex;
          flex-flow: row wrap;
          justify-content: center;
          padding: 1vw;
          gap: 1vw;
          background-color: rgba(1, 0, 32, 0.75);
          box-shadow: inset 0 0 0.5vw #010020;

          button {
            font-size: 1.25vw;
            line-height: 1.25vw;
            padding: 1vw 2vw;
            color: #dedede;
            background-color: rgba(36, 65, 189, 0.75);
            border: 0.1vw solid rgba(51, 226, 230, 0.25);
            border-radius: 1vw;

            &:hover,
            &:active {
              color: rgba(51, 226, 230, 0.9);
              text-shadow: 0 0 0.1vw rgba(51, 226, 230, 0.5);
              background-color: rgba(45, 90, 216, 0.9);
            }
          }
        }

        img {
          width: 12.5vw;
          height: auto;
          cursor: default;
        }

        &:hover,
        &:active {
          transform: none;
        }
      }

      .tabs-wrapper {
        width: 95%;
        padding-bottom: 1vw;

        .tabs-container {
          padding: 0;
          display: flex;
          flex-flow: row nowrap;
          justify-content: space-between;
          align-items: center;
          font-size: 1.25vw;
          line-height: 1.25vw;

          .tab {
            position: relative;
            margin: 0;
            padding: 1vw 4vw;
            background-color: rgba(51, 226, 230, 0.25);
            color: rgba(51, 226, 230, 0.9);
            border: none;
            border-bottom-left-radius: 0;
            border-bottom-right-radius: 0;
            transform: none !important;
            filter: none !important;

            &:hover,
            &:active {
              background-color: rgba(51, 226, 230, 0.5);
            }

            svg {
              position: absolute;
            }

            .connections-icon {
              left: 102.5%;
            }

            .stories-icon {
              right: 102.5%;
            }
          }
        }

        .tab-section {
          padding: 1vw;
          background-color: rgba(51, 226, 230, 0.1);
          box-shadow: inset 0 0 0.5vw rgba(51, 226, 230, 0.25);
          border-radius: 1vw;
          border-top-left-radius: 0;
          border-top-right-radius: 0;
          font-size: 1vw;

          .empty-note {
            font-size: 2vw;
            color: rgba(51, 226, 230, 0.5);
            margin-block: 2.5vw !important;
          }

          .connected-characters {
            display: flex;
            flex-flow: column nowrap;
            align-items: center;
            justify-content: center;
            gap: 1vw;

            h2 {
              text-align: center;
              width: 100%;
              padding-block: 1vw;
              background-color: rgba(51, 226, 230, 0.25);
              box-shadow:
                inset 0 0 0.5vw #010020,
                0 0.5vw 0.5vw #010020;
              border-radius: 1vw;
            }

            .characters-section {
              width: 100%;
              display: flex;
              flex-flow: row wrap;
              align-items: center;
              justify-content: center;
              gap: 1vw;

              div {
                display: flex;
                flex-flow: column nowrap;
                align-items: center;
                width: 15vw;
                height: auto;
                padding: 0.5vw;
                gap: 0.5vw;
                cursor: pointer;
                transition: all 0.3s ease-in-out;
                background-color: rgba(36, 65, 189, 0.9);
                border: 0.2vw solid gray;
                border-radius: 1vw;
                outline: none;
                font-size: 1.5vw;
                line-height: 2.5vw;
                text-align: center;
                box-shadow: 0 0 0.5vw #010020;

                img {
                  width: 100%;
                  height: inherit;
                  border-radius: 0.5vw;
                }

                &:hover,
                &:active {
                  background-color: rgb(45, 90, 216);
                  color: rgba(51, 226, 230, 0.9);
                  box-shadow: 0 0.5vw 0.5vw #010020;
                  transform: scale(1.025) translateY(-0.5vw);
                }
              }
            }
          }

          .stories {
            display: flex;
            flex-flow: column nowrap;
            align-items: center;
            justify-content: center;
            gap: 1vw;

            h2 {
              text-align: center;
              margin-bottom: 0.5vw;
            }
          }
        }
      }

      .transformation {
        display: flex;
        flex-flow: row nowrap;
        justify-content: center;
        align-items: center;
        gap: 1vw;
        font-size: 1vw;
        padding-inline: 1vw;

        div {
          display: flex;
          flex-flow: column nowrap;
          justify-content: center;
          align-items: center;

          img {
            width: 15vw;
            height: inherit;
            box-shadow: inset 0 0 0.5vw #010020;
            border-radius: 7.5vw;
            margin-bottom: 0.5vw;
            cursor: zoom-in;

            &:hover {
              z-index: 20;
              transform: scale(1.5);
              filter: drop-shadow(0 0 1rem rgba(51, 226, 230, 0.25));
            }

            &:active {
              transform: scale(2.5);
            }
          }
        }

        span {
          font-size: 2vw;
        }
      }
    }
  }

  .dischordian-saga {
    display: flex;
    flex-flow: column nowrap;
    justify-content: center;
    align-items: center;
    gap: 2vw;

    .wrapper {
      width: 100%;
      display: flex;
      flex-flow: column nowrap;
      justify-content: center;
      align-items: center;
    }

    .opener {
      width: 95%;
      transform: none !important;

      span {
        color: rgb(255, 60, 64);
        text-shadow: 0 0 0.25rem #010020;
      }

      svg {
        height: 1.5vw;
        width: 1.5vw;
        filter: drop-shadow(0 0 0.25rem #010020);
      }
    }

    .timeline-container {
      width: 95%;
      padding: 1vw;
      background-color: rgba(51, 226, 230, 0.1);
      border: 0.1vw solid rgba(51, 226, 230, 0.25);
      border-bottom-right-radius: 1vw;
      border-bottom-left-radius: 1vw;
      display: flex;
      flex-flow: column nowrap;
      justify-content: center;
      align-items: center;
      gap: 0;
      font-size: 1vw;

      .episodes {
        display: flex;
        flex-flow: column nowrap;
        align-items: center;
        justify-content: center;
        gap: 1vw;

        h2 {
          text-align: center;
        }
      }
    }

    .month-system {
      width: 100%;
      display: flex;
      flex-flow: column nowrap;
      justify-content: center;
      align-items: center;
    }
  }

  .history {
    max-width: 95%;
    color: #dedede;
    font-size: 1vw;
  }

  dialog::backdrop {
    background: rgba(0, 0, 0, 0.25);
    -webkit-backdrop-filter: blur(1rem);
    backdrop-filter: blur(1rem);
  }

  dialog[open] {
    animation: zoom 0.3s cubic-bezier(0.075, 0.82, 0.165, 1);
  }

  dialog[open]::backdrop {
    animation: fade 0.2s ease-out;
  }

  dialog::-webkit-scrollbar {
    width: 0.5vw;
  }

  dialog::-webkit-scrollbar-track {
    background-color: rgba(0, 0, 0, 0);
  }

  dialog::-webkit-scrollbar-thumb {
    background: linear-gradient(
      to bottom,
      rgba(0, 0, 0, 0),
      rgba(51, 226, 230, 0.5),
      rgba(0, 0, 0, 0)
    );
    border-radius: 0.5vw;
    cursor: pointer;
  }

  dialog::-webkit-scrollbar-thumb:hover,
  dialog::-webkit-scrollbar-thumb:active {
    background: rgba(51, 226, 230, 0.5);
  }

  @media only screen and (max-width: 600px) {
    .fullscreen-picture {
      height: 100vh;

      img {
        width: 100vw;
        height: auto;
        border: none;
      }
    }

    .timeline-title {
      font-size: 1.5em;
      line-height: 1.5em;
    }

    dialog::backdrop {
      background: #010020;
    }

    dialog {
      min-height: 100%;
      height: 100%;
      min-width: 100vw;
      width: 100vw;
      border-radius: 0;

      main {
        padding-bottom: 1em;

        header {
          padding: 1em;
          border-radius: 0;

          div {
            padding-inline: 1em;
            gap: 1em;

            svg {
              width: 2em;
              height: 2em;
            }

            h1 {
              font-size: 1.5em;
              line-height: 1.25em;
            }
          }

          .close-button,
          .back-arrow {
            padding: 0.35em;

            svg {
              width: 1.5em;
              height: 1.5em;
            }
          }
        }

        .character-window {
          gap: 1.5em;

          .general-info {
            flex-direction: column;
            width: 100vw;
            padding: 1em;
            border-radius: 0;
            border-top: 0.1vw solid rgba(51, 226, 230, 0.25);
            border-bottom: 0.1vw solid rgba(51, 226, 230, 0.25);
            box-shadow: none;
            gap: 1em;

            .image-container {
              width: 90vw;
              min-width: 90vw;
              border-radius: 0.5em;
              box-shadow: none;

              img {
                width: inherit;
                height: 90vw;
              }

              button {
                border-bottom-left-radius: 0.5em;
                border-bottom-right-radius: 0.5em;
                font-size: 1.25em;
              }

              div {
                height: 3em;

                .opensea {
                  border-bottom-left-radius: 0.5em;
                }

                .magiceden {
                  border-bottom-right-radius: 0.5em;
                }

                a {
                  width: 45vw;

                  img {
                    width: auto;
                    height: 1.5em;
                  }
                }
              }
            }

            article {
              min-height: none;
              gap: 1em;
              font-size: 1em;

              .status {
                align-items: center;
                gap: 0.5em;
                font-size: 1.25em;

                span {
                  gap: 0.5em;
                }
              }
            }
          }

          .play-button {
            width: 95vw;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 0.5em;
            gap: 0.5em;
            font-size: 1.5em;
            line-height: 1em;
            color: #010020;
            border-radius: 0.5em;

            p {
              text-align: center;
              width: 95vw;
            }

            div {
              width: 100%;
              padding: 0.5em;
              gap: 0.5em;

              button {
                font-size: 0.75em;
                line-height: 1em;
                padding: 0.5em 1em;
                border-radius: 0.25em;
              }
            }

            img {
              height: 1em;
              width: auto;
            }
          }

          .transformation {
            flex-direction: column;
            gap: 1em;
            font-size: 1em;
            line-height: 1em;
            padding-inline: 0.5em;

            div {
              img {
                width: 50vw;
                border-radius: 25vw;
                margin-bottom: 0.5em;
              }
            }

            span {
              font-size: 1.5em;
              transform: rotate(90deg);
            }
          }

          .tabs-wrapper {
            width: 100vw;
            padding-bottom: 1vw;

            .tabs-container {
              font-size: 1.25em;
              line-height: 1.5em;

              .tab {
                font-size: inherit;
                line-height: inherit;
                width: 50vw;
                padding: 0.25em;
                border-radius: 0;
              }
            }

            .tab-section {
              padding: 1em 0.5em;
              border-radius: 0;
              font-size: 1em;
              border-left: none;
              border-right: none;

              .empty-note {
                font-size: 1.5em;
              }

              .connected-characters {
                text-align: center;
                gap: 0.5em;

                h2 {
                  padding-block: 0.5em;
                  border-radius: 0.5em;
                }

                .characters-section {
                  gap: 1em;

                  div {
                    width: 40vw;
                    padding: 0.25em;
                    gap: 0.25em;
                    border-radius: 0.5em;
                    font-size: 1em;
                    line-height: 1.5em;

                    img {
                      width: 100%;
                      border-radius: 0.25em;
                    }
                  }
                }
              }

              .stories {
                gap: 1em;
              }
            }
          }
        }

        .dischordian-saga {
          gap: 1.5em;

          .opener {
            width: 100%;
            border-radius: 0;
            border-left: none;
            border-right: none;
            font-size: 1.25em;
            gap: 0.5em;

            svg {
              height: 1em;
              width: 1em;
            }
          }

          .timeline-container {
            width: 100vw;
            font-size: 1em;
            line-height: 1.75em;
            padding: 1em;
            border-radius: 0;
            border-left: none;
            border-right: none;
          }

          .month-system {
            padding-inline: 1em;
            font-size: 1em;
          }
        }

        .history {
          max-width: none;
          padding-inline: 1em;
          font-size: 1em;
        }
      }
    }

    dialog::-webkit-scrollbar {
      width: 0;
    }
  }

  @keyframes zoom {
    from {
      transform: scale(1.5);
    }
    to {
      transform: scale(1);
    }
  }

  @keyframes fade {
    from {
      opacity: 0;
    }
    to {
      opacity: 1;
    }
  }
</style>
