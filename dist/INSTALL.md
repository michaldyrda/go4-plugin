# Instalacja go4.fashion w Claude Desktop

Krótka instrukcja dla managera. **Robisz to raz**, potem Claude wie wszystko o go4.fashion.

## Co dostaniesz

Po instalacji możesz w Claude pisać po polsku rzeczy w stylu:

- "Wczytaj to zamówienie z PDF" → Claude zaimportuje je do go4
- "Wystaw fakturę dla Acme za zamówienie 1234" → Claude przeprowadzi cały cykl billingowy
- "Dodaj koszt z tej faktury PDF" → Claude założy expense
- "Zrób raport za marzec" → Claude zbierze statystyki, faktury, koszty
- "Zamów materiały na kolekcję SS26" → Claude policzy zapotrzebowanie i przygotuje zamówienia
- ...i ~30 innych operacji go4.fashion

## Czego potrzebujesz

- **Claude Desktop** zainstalowany na Macu albo Windowsie ([pobierz tutaj](https://claude.ai/download))
- Konto Claude **Pro, Max, Team albo Enterprise** (Free plan nie obsługuje skili)

## Krok 1: Dodaj connector go4 (jednorazowo)

To jest połączenie z Twoimi danymi w go4.fashion.

1. Otwórz Claude Desktop
2. **Settings → Connectors → Add custom connector**
3. Wklej URL:
   ```
   https://web-production-bdb8f.up.railway.app/mcp
   ```
4. Nazwa: `go4`
5. Kliknij **Add**
6. Claude otworzy okno logowania go4.fashion → zaloguj się swoim zwykłym kontem
7. Po zalogowaniu connector pokaże się jako **Connected** ✅

Od tej pory Claude widzi Twoje zamówienia, klientów, materiały, faktury, etc. Tylko Twoje — nikt inny nie ma dostępu.

## Krok 2: Wgraj skill go4-fashion (jednorazowo)

To jest "instrukcja obsługi" — Claude bez tego widzi narzędzia, ale nie wie jak ich używać po Twojemu.

1. Pobierz plik **`go4-fashion.zip`** (link od Michała)
2. W Claude Desktop: **Customize → Skills → + Create skill → Upload a skill**
3. Wskaż pobrany ZIP
4. Skill pojawi się na liście jako **go4-fashion**
5. Upewnij się że jest **włączony** (toggle po prawej)

Gotowe.

## Krok 3: Test

Otwórz nowy chat w Claude i napisz:

> Sprawdź połączenie z go4

Claude powinien wywołać `test_connection` i odpowiedzieć że połączenie działa. Jeśli tak — wszystko gotowe.

Spróbuj potem:

> Pokaż mi 5 ostatnich zamówień

albo

> Co to jest go4.fashion i co potrafisz?

## Aktualizacje

Gdy Michał wyśle Ci nowy `go4-fashion.zip`:

1. **Customize → Skills**
2. Znajdź `go4-fashion` na liście → **Delete**
3. **+ Create skill → Upload a skill** → wskaż nowy ZIP

(W przyszłości aktualizacje będą automatyczne — na razie ręcznie.)

## Problemy

**Skill jest w liście, ale Claude nie używa narzędzi go4** → sprawdź czy connector go4 jest **Connected** w Settings → Connectors. Skill bez connectora to tylko instrukcja, bez dostępu do danych.

**Connector pokazuje błąd autoryzacji** → usuń connector i dodaj jeszcze raz, zaloguj się od nowa.

**Claude pyta o rzeczy które powinien wiedzieć** → upewnij się że skill `go4-fashion` jest **włączony** (toggle ON) w Customize → Skills.

**Cokolwiek innego** → napisz do Michała, opisz co się dzieje i wklej co odpowiedział Claude.
