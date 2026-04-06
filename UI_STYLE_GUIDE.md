# UI Style Guide — zloma_garages

Kompletan referentni dokument za dizajn sistem korišten u ovom projektu.
Koristi ovo kao template pri izradi novih UI-a i skripti.

---

## 1. Dizajn Filozofija

- **Monokromatski dark theme** — gotovo sve je nijansa crne/sive, bez accent boja kao primarnih
- **Minimalistički** — čiste linije, bez suvišnih dekoracija
- **Glass-morphism efekti** — polu-transparentni paneli s blur-om
- **Micro-animacije** — suptilni fade/slide/scale efekti kratkog trajanja (150–200ms)
- **Icon library** — `lucide-svelte` (ili `lucide-react` / `lucide` za druge frameworke)

---

## 2. Paleta Boja

### Dark (primarna baza za sve pozadine)

| Token        | Hex       | Namjena                                      |
|--------------|-----------|----------------------------------------------|
| `dark-950`   | `#0a0a0a` | Najdublja pozadina (glass-dark)              |
| `dark-900`   | `#171717` | Glavna pozadina panela, inputi, kartice      |
| `dark-800`   | `#262626` | Sekundarna pozadina, hover stanja            |
| `dark-700`   | `#404040` | Borderi, divajderi, scrollbar thumb          |
| `dark-600`   | `#525252` | Hover borderi, scrollbar thumb hover         |
| `dark-500`   | `#737373` | Placeholder tekst, deaktivne ikone           |
| `dark-400`   | `#a3a3a3` | Sekundarni tekst, labele                     |
| `dark-300`   | `#d4d4d4` | Tertijerni tekst, ikone u normalnom stanju   |
| `dark-200`   | `#e5e5e5` | Hover tekst                                  |
| `dark-100`   | `#f5f5f5` | Gotovo bijeli tekst (rijetko)                |
| `dark-50`    | `#fafafa`  | Bijeli hover (btn-primary hover)             |

### Semantičke boje (status, feedback)

| Token            | Hex       | Namjena                              |
|------------------|-----------|--------------------------------------|
| `success-500`    | `#22c55e` | Vehicle available, goriva OK, health OK |
| `success-400`    | `#86efac` | Health text u dobrom stanju          |
| `warning-500`    | `#f59e0b` | Impound status, goriva <50%          |
| `warning-400`    | `#fcd34d` | Warning tekst                        |
| `danger-500`     | `#ef4444` | Vehicle out, greška, brisanje        |
| `danger-600`     | `#dc2626` | btn-danger pozadina                  |
| `danger-400`     | `#fca5a5` | Danger tekst                         |

### Akcent boje (rijetko, specifičan kontekst)

| Boja              | Hex              | Gdje se koristi                         |
|-------------------|------------------|-----------------------------------------|
| `blue-500`        | `#3b82f6`        | "Stored elsewhere" status dot           |
| `blue-400`        | `#60a5fa`        | badge-primary tekst                     |
| `cyan-500`        | `#06b6d4`        | "On sale" status, player-assigned badge |
| `purple-500/90`   | rgba purple      | "Shared with me" badge                  |
| `amber-500/90`    | rgba amber       | Grade assignment badge                  |
| `orange-500/90`   | rgba orange      | statusText badge                        |

### Bijela (za primarne akcije)

- `white` — btn-primary pozadina, glavni naslovi, spawnable dugme
- `text-white` — primarni tekst na tamnim pozadinama

---

## 3. Tipografija

### Fontovi

```css
font-family: 'Inter', system-ui, -apple-system, sans-serif;
font-family: 'JetBrains Mono', Consolas, monospace; /* za plate/ID vrijednosti */
```

- **Globalni:** Inter, `-webkit-font-smoothing: antialiased`, `letter-spacing: -0.01em`
- **Mono klasa:** `font-mono` za tablice registarskih oznaka, identifikatore, mileage

### Veličine i stilovi

| Primjena             | Klase                                              |
|----------------------|----------------------------------------------------|
| Panel naslov (H2)    | `text-xl font-bold text-white`                     |
| Sekcijski naslov     | `text-lg font-semibold text-white`                 |
| Vehicle ime          | `text-lg font-bold tracking-tight text-white`      |
| Podnaslovi           | `text-sm text-dark-400`                            |
| Labele / meta info   | `text-xs text-dark-400 uppercase tracking-wider`   |
| Label za statistike  | `text-[10px] uppercase font-semibold text-dark-500 tracking-wider` |
| Plate / ID           | `text-xs font-mono text-primary-400`               |
| Mono vrijednosti     | `font-mono text-dark-400`                          |
| Badge tekst          | `text-xs font-medium uppercase tracking-wider`     |
| Hover promjena boje  | `group-hover:text-primary-400 transition-colors`   |

---

## 4. Komponente — Klase

### Glass Efekti (paneli)

```css
/* Standardni panel */
.glass {
  background-color: rgba(23, 23, 23, 0.97);
  border: 1px solid rgba(64, 64, 64, 0.5);
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.4), 
              inset 0 1px 0 rgba(255, 255, 255, 0.05);
}

/* Tamniji, za glavne modalne prozore */
.glass-dark {
  background-color: rgba(10, 10, 10, 0.98);
  border: 1px solid rgba(38, 38, 38, 0.6);
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.6), 
              inset 0 1px 0 rgba(255, 255, 255, 0.03);
}
```

**Upotreba:** `glass-dark rounded-2xl overflow-hidden flex flex-col max-h-[85vh]`

---

### Dugmad (Buttons)

#### Baze

```html
<!-- Primarna (bijela) -->
<button class="btn btn-primary">Akcija</button>
<!-- bg-white hover:bg-dark-50 text-dark-950 -->

<!-- Sekundarna (tamna) -->
<button class="btn btn-secondary">Akcija</button>
<!-- bg-dark-800 hover:bg-dark-700 text-dark-100 border border-dark-600/50 -->

<!-- Opasna (crvena) -->
<button class="btn btn-danger">Brisanje</button>
<!-- bg-danger-600 hover:bg-danger-500 text-white -->

<!-- Ghost (transparentna) -->
<button class="btn btn-ghost">Opcija</button>
<!-- bg-transparent hover:bg-dark-800 text-dark-300 hover:text-white -->

<!-- Mala -->
<button class="btn btn-primary btn-sm">Mali</button>
```

#### Base `.btn` klasa

```css
.btn {
  padding: 0.625rem 1rem;           /* px-4 py-2.5 */
  border-radius: 0.5rem;            /* rounded-lg */
  font-weight: 500;                 /* font-medium */
  transition: all 150ms;
  display: flex; align-items: center; justify-content: center; gap: 0.5rem;
  active:scale-[0.98];              /* micro feedback na klik */
  disabled:opacity-40 disabled:cursor-not-allowed;
}
```

#### Icon-only dugmad (česta upotreba)

```html
<!-- Close dugme (panel header) -->
<button class="w-10 h-10 rounded-lg bg-dark-700/50 hover:bg-dark-600 
               flex items-center justify-center transition-colors">
  <X class="w-5 h-5 text-dark-300" />
</button>

<!-- Icon action dugme (edit/delete/teleport) -->
<button class="p-2 rounded-lg bg-dark-700 hover:bg-dark-600 
               text-dark-400 hover:text-white transition-colors">
  <Edit class="w-4 h-4" />
</button>

<!-- Delete icon (hover u danger) -->
<button class="p-2 rounded-lg bg-dark-700 hover:bg-danger-500/20 
               text-dark-400 hover:text-danger-400 transition-colors">
  <Trash2 class="w-4 h-4" />
</button>
```

---

### Inputi

```html
<!-- Standardni input -->
<input class="input" type="text" placeholder="..." />

<!-- Search input s ikonom -->
<div class="relative flex-1">
  <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 
                 text-dark-400 pointer-events-none" />
  <input class="input !pl-10 py-2" type="text" placeholder="Search..." />
</div>
```

```css
.input {
  width: 100%;
  padding: 0.75rem 1rem;            /* px-4 py-3 */
  border-radius: 0.5rem;            /* rounded-lg */
  background: #171717;              /* bg-dark-900 */
  border: 1px solid #404040;        /* border-dark-700 */
  color: white;
  placeholder: #737373;             /* dark-500 */
  focus: border-dark-500, ring-1 ring-dark-500/30;
  transition: all 150ms;
}
```

---

### Select (Dropdown)

```html
<select class="select">
  <option value="name">By Name</option>
</select>
```

```css
.select {
  /* Iste baze kao .input */
  appearance: none;
  cursor: pointer;
  /* Custom arrow ikona (SVG inline, boja #737373) */
  background-image: url("data:image/svg+xml,...chevron...");
  background-position: right 0.75rem center;
  background-repeat: no-repeat;
  background-size: 1.25em 1.25em;
  padding-right: 2.5rem;
}
```

---

### Badge

```html
<span class="badge badge-success">Available</span>
<span class="badge badge-warning">Impounded</span>
<span class="badge badge-danger">Out</span>
<span class="badge badge-primary">Info</span>
<span class="badge badge-info">Highlight</span>
<span class="badge badge-accent">Neutral</span>
```

```css
.badge       { padding: 4px 10px; font-size: 12px; font-weight: 500; 
               border-radius: 6px; text-transform: uppercase; letter-spacing: 0.05em; }
.badge-success { bg: success-500/10; color: success-400; border: success-500/20; }
.badge-warning { bg: warning-500/10; color: warning-400; border: warning-500/20; }
.badge-danger  { bg: danger-500/10;  color: danger-400;  border: danger-500/20;  }
.badge-primary { bg: blue-500/10;    color: blue-400;    border: blue-500/20;    }
.badge-info    { bg: cyan-500;       color: white;       border: cyan-600; font-bold; }
.badge-accent  { bg: dark-700;       color: dark-300;    border: dark-600/50;    }
```

---

### Kartice (Cards)

```html
<!-- Statična kartica -->
<div class="card p-4">...</div>

<!-- Interaktivna kartica -->
<button class="card card-hover w-full text-left">...</button>

<!-- Kartica s dashed border (create new) -->
<button class="card card-hover w-full p-4 border-dashed border-2 
               border-dark-600 hover:border-primary-500">
  ...
</button>
```

```css
.card {
  background: rgba(23,23,23,0.6);   /* bg-dark-900/60 */
  border-radius: 0.5rem;
  border: 1px solid rgba(64,64,64,0.4);   /* border-dark-700/40 */
  backdrop-filter: blur(4px);
  transition: all 150ms;
  overflow: hidden;
}
.card-hover {
  hover: border-dark-600; 
  hover: bg-dark-800/60; 
  cursor: pointer;
}
```

---

### Status Indikatori (dot)

```html
<div class="status-available"></div>   <!-- ● zelena -->
<div class="status-out"></div>          <!-- ● crvena -->
<div class="status-impound"></div>      <!-- ● žuta -->
<div class="status-police"></div>       <!-- ● tamno crvena (intenzivna) -->
<div class="status-stored-elsewhere"></div> <!-- ● plava -->
<div class="status-on-sale"></div>      <!-- ● cyan -->
```

```css
/* Svaki je: w-2 h-2 rounded-full + boja + glow shadow */
.status-available       { bg: #22c55e; shadow: 0 0 6px rgba(34,197,94,0.4); }
.status-out             { bg: #ef4444; shadow: 0 0 6px rgba(239,68,68,0.4); }
.status-impound         { bg: #f59e0b; shadow: 0 0 6px rgba(245,158,11,0.4); }
.status-police          { bg: #dc2626; shadow: 0 0 8px rgba(220,38,38,0.6); }
.status-stored-elsewhere{ bg: #3b82f6; shadow: 0 0 6px rgba(59,130,246,0.4); }
.status-on-sale         { bg: #06b6d4; shadow: 0 0 6px rgba(6,182,212,0.4); }
```

---

### Progress Bar

```html
<!-- Container -->
<div class="h-1.5 w-full bg-dark-800 rounded-full overflow-hidden">
  <!-- Fill (dinamička širina) -->
  <div class="h-full rounded-full transition-all duration-500 bg-emerald-500"
       style="width: {value}%">
  </div>
</div>
```

**Boje filla po vrijednosti:**
- Gorivo ≥ 20 → `bg-emerald-500`
- Gorivo < 20 → `bg-danger-500`
- Health ≥ 70% → `bg-success-500`
- Health 40–70% → `bg-warning-500`
- Health < 40% → `bg-danger-500`

---

## 5. Layout Uzorci

### Glavni Modal / Panel

```html
<div class="glass-dark rounded-2xl overflow-hidden flex flex-col 
            max-h-[85vh] w-[95vw] max-w-[1600px]">

  <!-- HEADER -->
  <div class="px-6 py-4 border-b border-dark-700 
              flex items-center justify-between relative">
    
    <!-- Centralni naslov (apsolutno pozicioniran) -->
    <div class="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 text-center">
      <h2 class="text-xl font-bold text-white">Panel Naslov</h2>
      <p class="text-sm text-dark-400">Podnaslov</p>
    </div>

    <!-- Close dugme desno -->
    <button class="w-10 h-10 rounded-lg bg-dark-700/50 hover:bg-dark-600 
                   flex items-center justify-center transition-colors ml-auto">
      <X class="w-5 h-5 text-dark-300" />
    </button>
  </div>

  <!-- TABS (opcionalno) -->
  <div class="px-6 border-b border-dark-700/50 flex items-center gap-1">
    <!-- Tab dugmad (vidi sekciju) -->
  </div>

  <!-- CONTENT -->
  <div class="flex-1 overflow-y-auto p-4">
    <!-- sadržaj -->
  </div>

</div>
```

---

### Tabs — Dva stila

#### Stil 1: Underline tabs (Garage tipovi)

```html
<button class="px-4 py-3 text-sm font-medium transition-all relative
               {active ? 'text-primary-400' : 'text-dark-400 hover:text-dark-200'}">
  <div class="flex items-center gap-2">
    <Icon class="w-4 h-4" />
    <span>Label</span>
  </div>
  <!-- Aktivni underline -->
  {#if active}
    <div class="absolute bottom-0 left-0 right-0 h-0.5 bg-primary-500"></div>
  {/if}
</button>
```

#### Stil 2: Pill tabs (Admin panel, filter toggle)

```html
<button class="px-4 py-2 rounded-lg text-sm font-medium transition-colors
               {active 
                 ? 'bg-primary-500/20 text-primary-400' 
                 : 'text-dark-400 hover:text-white hover:bg-dark-700'}">
  <span class="flex items-center gap-2">
    <Icon class="w-4 h-4" />
    Label
  </span>
</button>
```

#### Stil 3: Segment control (Police impound filter)

```html
<div class="flex items-center bg-dark-800 rounded-lg p-1 border border-dark-700">
  <button class="px-4 py-1.5 rounded-md text-xs font-bold flex items-center gap-2 transition-all
                 {active 
                   ? 'bg-dark-600 text-white shadow-sm ring-1 ring-white/10' 
                   : 'text-dark-400 hover:text-dark-200 hover:bg-dark-700/50'}">
    <Icon class="w-3.5 h-3.5" />
    Label
  </button>
  <div class="w-px h-4 bg-dark-700 mx-1"></div>
  <!-- ostale opcije... -->
</div>
```

---

### Toolbar / Filter Bar

```html
<div class="px-6 py-3 border-b border-dark-700/50 flex items-center gap-3">
  
  <!-- Search -->
  <div class="relative flex-1">
    <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 
                   text-dark-400 pointer-events-none" />
    <input class="input !pl-10 py-2" type="text" placeholder="..." />
  </div>

  <!-- Icon group (toggle buttons) -->
  <div class="flex items-center gap-1 bg-dark-800 rounded-lg p-1">
    <button class="p-2 rounded-md hover:bg-dark-700 text-dark-400 hover:text-white transition-colors">
      <Icon class="w-4 h-4" />
    </button>
  </div>

  <!-- Toggle dugme (filtri on/off) -->
  <button class="p-2.5 rounded-lg transition-colors
                 {active 
                   ? 'bg-primary-500/20 text-primary-400' 
                   : 'bg-dark-700 text-dark-300 hover:bg-dark-600'}">
    <SlidersHorizontal class="w-4 h-4" />
  </button>

</div>
```

---

### Vehicle Card Layout

```html
<button class="card card-hover group text-left w-full overflow-hidden
               {selected ? 'border-primary-500 ring-1 ring-primary-500/30' : 'border-dark-700/40'}">

  <!-- IMAGE ZONA (h-48) -->
  <div class="relative w-full h-48 flex-shrink-0 overflow-hidden bg-dark-800">
    <img class="w-full h-full object-cover transition-transform duration-500 
                group-hover:scale-105" ... />

    <!-- Gradient overlay odozdo -->
    <div class="absolute inset-x-0 bottom-0 h-24 
                bg-gradient-to-t from-dark-900 via-dark-900/60 to-transparent"></div>

    <!-- Status badge gore lijevo -->
    <div class="absolute top-3 left-3 flex flex-col gap-1.5">
      <div class="backdrop-blur-md bg-dark-900/80 border border-white/10 
                  px-2 py-1 rounded-md shadow-lg flex items-center gap-2">
        <div class="status-available"></div>
        <span class="text-xs font-semibold tracking-wide text-white uppercase">Available</span>
      </div>
      <!-- Dodatni badges ispod... -->
    </div>

    <!-- Hover overlay s akcijama -->
    <div class="absolute inset-0 flex items-center justify-center gap-2 
                bg-black/40 backdrop-blur-[2px] 
                opacity-0 group-hover:opacity-100 transition-all duration-300 
                translate-y-2 group-hover:translate-y-0">
      <button class="w-10 h-10 rounded-xl bg-white text-dark-950 
                     hover:scale-105 shadow-xl flex items-center justify-center transition-all">
        <Play class="w-5 h-5 fill-current" />
      </button>
      <button class="w-10 h-10 rounded-xl bg-dark-800/90 text-white 
                     hover:bg-dark-700 hover:scale-105 shadow-xl 
                     flex items-center justify-center border border-white/10 transition-all">
        <Share2 class="w-4 h-4" />
      </button>
    </div>
  </div>

  <!-- INFO ZONA -->
  <div class="p-4">
    <h3 class="text-white font-bold truncate text-lg tracking-tight 
               group-hover:text-primary-400 transition-colors">
      Vehicle Name
    </h3>
    <span class="bg-dark-800/50 px-1.5 py-0.5 rounded border border-dark-700 
                 font-mono text-xs text-dark-400">AB123CD</span>

    <!-- Progress bars grid -->
    <div class="grid grid-cols-2 gap-3 mt-4 pt-3 border-t border-dark-800">
      <!-- Fuel -->
      <div class="flex flex-col gap-1">
        <div class="flex items-center justify-between text-[10px] uppercase 
                    font-semibold text-dark-500 tracking-wider">
          <span>Fuel</span>
          <span class="text-dark-300">75%</span>
        </div>
        <div class="h-1.5 w-full bg-dark-800 rounded-full overflow-hidden">
          <div class="h-full rounded-full bg-emerald-500 transition-all duration-500"
               style="width: 75%"></div>
        </div>
      </div>
      <!-- Health (isti pattern) -->
    </div>
  </div>

</button>
```

---

### Badges na slici (stacking)

Svi badge-ovi na vehicle slici slijede isti pattern, razlikuju se samo boje pozadine:

```html
<div class="backdrop-blur-md {bg-color} border border-white/10 
            px-2 py-0.5 rounded shadow-lg 
            text-[10px] font-bold text-white uppercase tracking-wider self-start">
  Tekst
</div>
```

| Kontekst             | Pozadina            |
|----------------------|---------------------|
| Shared with me       | `bg-purple-500/90`  |
| Shared by me         | `bg-blue-500/90`    |
| Grade assignment     | `bg-amber-500/90`   |
| Player assignment    | `bg-cyan-500/90`    |
| Custom statusText    | `bg-orange-500/90`  |

---

### Modal Overlay

```html
<div class="fixed inset-0 bg-black/75 flex items-center justify-center p-4 
            z-[90] animate-fade-in"
     on:click={handleBackdropClick}>
  <div class="animate-scale-in">
    <!-- Panel sadržaj -->
  </div>
</div>
```

---

### Empty State

```html
<div class="flex flex-col items-center justify-center h-full text-center py-12">
  <Car class="w-16 h-16 text-dark-600 mb-4" />
  <p class="text-dark-400 text-lg">Nema vozila</p>
  <p class="text-dark-500 text-sm mt-1">Podnaslov poruka</p>
</div>
```

---

### Info/Highlight Blok

```html
<!-- Purple highlight (share info) -->
<div class="bg-gradient-to-r from-purple-500/10 to-blue-500/10 
            border border-purple-500/30 rounded-xl p-4">
  <div class="flex items-center gap-3">
    <div class="w-8 h-8 rounded-lg bg-purple-500/20 flex items-center justify-center">
      <Share2 class="w-4 h-4 text-purple-400" />
    </div>
    <div>
      <span class="text-sm font-semibold text-white">Naslov</span>
      <p class="text-xs text-dark-400">Opis tekst</p>
    </div>
  </div>
</div>

<!-- Neutralni info blok -->
<div class="bg-dark-800/50 rounded-xl p-4 border border-dark-700">
  <!-- sadržaj -->
</div>
```

---

## 6. Scrollbar

```css
::-webkit-scrollbar       { width: 8px; height: 8px; }
::-webkit-scrollbar-track { background: #171717; border-radius: 4px; }
::-webkit-scrollbar-thumb { background: #404040; border-radius: 4px; 
                             border: 2px solid #171717; }
::-webkit-scrollbar-thumb:hover { background: #525252; }
```

---

## 7. Box Shadows

| Token          | Vrijednost                                         | Namjena                   |
|----------------|----------------------------------------------------|---------------------------|
| `glow-sm`      | `0 0 10px rgba(255,255,255,0.05)`                  | Suptilni glow             |
| `glow`         | `0 0 20px rgba(255,255,255,0.08)`                  | Standardni glow           |
| `glow-lg`      | `0 0 40px rgba(255,255,255,0.12)`                  | Jači glow (glass-dark)    |
| `glow-accent`  | `0 0 20px rgba(148,163,184,0.15)`                  | Accent glow               |
| `brutal`       | `4px 4px 0px 0px rgba(0,0,0,0.25)`                 | Brutalist stil            |
| `brutal-lg`    | `8px 8px 0px 0px rgba(0,0,0,0.25)`                 | Brutalist stil veći       |

---

## 8. Animacije

| Klasa            | Keyframe                                          | Trajanje  |
|------------------|---------------------------------------------------|-----------|
| `animate-fade-in`  | opacity: 0 → 1                                  | 150ms ease-out |
| `animate-slide-up` | opacity: 0, Y+10px → opacity: 1, Y 0           | 200ms ease-out |
| `animate-slide-down`| opacity: 0, Y-10px → opacity: 1, Y 0          | 200ms ease-out |
| `animate-scale-in` | opacity: 0, scale(0.98) → opacity: 1, scale(1) | 150ms ease-out |
| `animate-pulse-glow`| box-shadow: glow-sm ↔ glow (pulsira)          | 3s infinite |

**Hover transition standard:** `transition-all duration-150` ili `transition-colors`

---

## 9. Z-Index Sistem

| Vrijednost | Namjena                        |
|------------|--------------------------------|
| `z-[90]`   | Modalni overlay (bg-black/75)  |
| `z-50`     | Dropdown meniji                |

---

## 10. Grid Uzorci

### Vehicle grid (responzivan)

```html
<!-- Kad nije selektovano vozilo -->
<div class="grid gap-3 grid-cols-1 md:grid-cols-2 lg:grid-cols-3 
            xl:grid-cols-4 2xl:grid-cols-5">

<!-- Kad je selektovano (detail panel zauzima prostora) -->
<div class="grid gap-3 grid-cols-1 lg:grid-cols-2 xl:grid-cols-3">
```

### Stats grid (2 kolone)

```html
<div class="grid grid-cols-2 gap-3">
  <div class="card p-3">
    <div class="flex items-center gap-2 mb-2">
      <Icon class="w-4 h-4 text-primary-400" />
      <span class="text-sm text-dark-400">Label</span>
    </div>
    <p class="text-lg font-bold text-white">Vrijednost</p>
  </div>
</div>
```

---

## 11. Boje po Garage/Impound Tipu

### Garage tipovi (badge boje)

| Tip             | Klase                                          |
|-----------------|------------------------------------------------|
| `private`       | `bg-success-500/20 text-success-400`           |
| `public`        | `bg-primary-500/20 text-primary-400`           |
| `organization`  | `bg-accent-500/20 text-accent-400`             |
| `infinitive`    | `bg-warning-500/20 text-warning-400`           |
| default         | `bg-dark-500/20 text-dark-400`                 |

### Impound tipovi (gradient pozadina)

| Tip             | Gradient                                           |
|-----------------|----------------------------------------------------|
| `personal`      | `from-warning-500/20 to-orange-500/20`             |
| `organization`  | `from-primary-500/20 to-blue-500/20`               |
| `police`        | `from-danger-500/20 to-red-500/20`                 |
| default         | `from-dark-500/20 to-dark-600/20`                  |

---

## 12. Ikone

Koristi **Lucide** (lucide-svelte / lucide-react / lucide):

| Kontekst           | Ikona                   |
|--------------------|-------------------------|
| Zatvori panel      | `X`                     |
| Pretraga           | `Search`                |
| Filtri             | `SlidersHorizontal`     |
| Automobil          | `Car`                   |
| Motor              | `Bike`                  |
| Helikopter/Avion   | `Plane`                 |
| Brod               | `Ship`                  |
| Dijeli             | `Share2`                |
| Korisnik           | `User`                  |
| Organizacija       | `Building2`             |
| Admin/Zaštita      | `Shield`                |
| Više korisnika     | `Users`                 |
| Zvjezdica/Rang     | `Star`                  |
| Gorivo             | `Fuel`                  |
| Brzinomjer         | `Gauge`                 |
| Zdravlje/Srce      | `Heart`                 |
| Alat/Popravak      | `Wrench`                |
| Uredi              | `Edit3` / `Edit`        |
| Transfer/Strelice  | `ArrowRightLeft`        |
| Brisanje           | `Trash2`                |
| Podešavanja        | `Settings`              |
| Lokacija           | `MapPin`                |
| Garaža             | `Warehouse`             |
| Upozorenje         | `AlertTriangle`         |
| Dodaj              | `Plus`                  |
| Play/Izvuci        | `Play`                  |
| Novac              | `DollarSign`            |
| Sat/Trajanje       | `Clock`                 |
| Zaključaj          | `Unlock`                |
| Munja/Brzo         | `Zap`                   |
| Filter             | `Filter`                |
| Sortiranje         | `ArrowUpDown`           |
| Chevron dolje      | `ChevronDown`           |

**Standardne veličine ikona:**
- `w-3.5 h-3.5` — u segment kontrolama
- `w-4 h-4` — toolbar, badge ikone, action dugmad
- `w-5 h-5` — header close, veće akcije
- `w-16 h-16` — empty state ilustracija

---

## 13. Brzi Cheatsheet

```
Tekst boje:
  Primarni naslov   → text-white
  Sekundarni        → text-dark-400
  Deaktivni/meta    → text-dark-500
  Hover tekst       → text-dark-200 / text-white
  Akcent/plate      → text-primary-400
  Danger            → text-danger-400
  Warning           → text-warning-400
  Success           → text-success-400

Pozadine:
  Panel             → bg-dark-900 (ili glass-dark)
  Kartica           → bg-dark-900/60
  Hover             → bg-dark-800
  Input             → bg-dark-900
  Sekundarna        → bg-dark-800

Border:
  Standard          → border-dark-700
  Suptilni          → border-dark-700/50
  Kartica           → border-dark-700/40
  Hover             → border-dark-600
  Active/Selected   → border-primary-500

Border-radius:
  Dugmad, input     → rounded-lg (8px)
  Kartice           → rounded-lg (8px)
  Paneli            → rounded-2xl (16px)
  Mali elementi     → rounded-md (6px)
  Kružni dot        → rounded-full

Spacing (uobičajeni):
  Panel padding     → px-6 py-4
  Kartica padding   → p-4
  Małi kartica      → p-3
  Gap između        → gap-2, gap-3, gap-4
```

---

## 14. Svelte/Framework Napomene

- Animacije na enter: `animate-fade-in`, `animate-scale-in` na wrapper elementu
- Slide animacije za panele koji se collapse-aju: `animate-slide-down`
- `group` / `group-hover:` pattern za hover efekte na cijeloj kartici
- `will-change: transform` na interaktivnim karticama za GPU acceleration
- `content-visibility: auto` na velikom gridu za performanse
- Tranzicije dugmad: uvijek `transition-all duration-150` ili `transition-colors`
