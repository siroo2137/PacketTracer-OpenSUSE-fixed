# Skrypt instalacyjny Cisco Packet Tracer dla openSUSE

[🇬🇧 English](README.md) | [🇵🇱 Polski](README_pl.md)

Ten skrypt automatyzuje instalację i deinstalację **Cisco Packet Tracer** na systemie **openSUSE Linux**. Jedynym wymaganiem jest umieszczenie pliku instalacyjnego **Packet Tracer `.deb`** w dowolnym katalogu w `/home` z domyślną nazwą pliku.

## Wymagania wstępne ⚙️

1. **openSUSE Linux** (testowane na openSUSE Tumbleweed-Slowroll).
2. Plik instalacyjny **Cisco Packet Tracer `.deb`** powinien znajdować się w katalogu **`/home`**.

## Kroki instalacji 🛠️

### 1. Pobierz Cisco Packet Tracer 💻

Pobierz instalator **Cisco Packet Tracer `.deb`** z jednego z poniższych źródeł:

* [NetAcad - Packet Tracer Download](https://www.netacad.com/portal/resources/packet-tracer)
* [Skills For All](https://skillsforall.com/resources/lab-downloads) (wymagane logowanie)

Upewnij się, że plik `.deb` został zapisany w katalogu **`/home`**.

### 2. Sklonuj skrypt 📂

Sklonuj repozytorium lub pobierz skrypt bezpośrednio na swój system:

```bash
git clone https://github.com/siroo2137/PacketTracer-OpenSUSE-fixed.git
```

### 3. Uruchom skrypt ▶️

Zainstaluj pakiet binutils:

```bash
sudo zypper install binutils
```

Następnie uruchom skrypt. Automatycznie zainstaluje on Cisco Packet Tracer poprzez:

* Wyszukanie instalatora `.deb` w katalogu `/home`.
* Instalację wymaganych zależności.
* Rozpakowanie i instalację Cisco Packet Tracer.

```bash
cd PacketTracer-OpenSUSE-fixed
chmod +x setup.sh
./setup.sh
```

Skrypt automatycznie wykona wszystkie kroki. Wyszuka plik `.deb`, odinstaluje istniejącą wersję Packet Tracer, zainstaluje wymagane zależności i skonfiguruje Cisco Packet Tracer.

### 4. Odinstalowanie Cisco Packet Tracer 🧹

Aby odinstalować Cisco Packet Tracer, uruchom skrypt z flagą `--uninstall`. Spowoduje to usunięcie programu oraz wszystkich powiązanych plików:

```bash
./setup.sh --uninstall
```

Skrypt:

* Usunie Packet Tracer z katalogu `/opt/pt`.
* Wyczyści wpisy w menu oraz inne pliki konfiguracyjne.
* Odinstaluje zależności i przywróci system do poprzedniego stanu.

Nie jest wymagana żadna dodatkowa konfiguracja — skrypt zajmie się wszystkim.
