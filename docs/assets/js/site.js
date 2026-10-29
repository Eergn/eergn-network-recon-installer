/* Eergn Network Recon Installer — shared interactions.
   No build step, no framework. Keeps the site usable without JavaScript. */
(function () {
  "use strict";

  var doc = document;

  function onReady(fn) {
    if (doc.readyState === "loading") {
      doc.addEventListener("DOMContentLoaded", fn, { once: true });
    } else {
      fn();
    }
  }

  function resolve(path) {
    var base = doc.body.getAttribute("data-base") || "";
    return base + path;
  }

  /* ------------------------------------------------------------ mobile nav */

  function initHeaderNav() {
    var toggle = doc.querySelector("[data-nav-toggle]");
    var nav = doc.getElementById("site-nav");
    if (!toggle || !nav) return;

    function close() {
      nav.classList.remove("is-open");
      toggle.setAttribute("aria-expanded", "false");
    }

    toggle.addEventListener("click", function () {
      var open = toggle.getAttribute("aria-expanded") === "true";
      if (open) {
        close();
      } else {
        nav.classList.add("is-open");
        toggle.setAttribute("aria-expanded", "true");
      }
    });

    nav.addEventListener("click", function (event) {
      if (event.target.closest("a")) close();
    });

    doc.addEventListener("keydown", function (event) {
      if (event.key === "Escape") close();
    });

    doc.addEventListener("click", function (event) {
      if (
        nav.classList.contains("is-open") &&
        !event.target.closest("#site-nav") &&
        !event.target.closest("[data-nav-toggle]")
      ) {
        close();
      }
    });

    var header = doc.querySelector("[data-header]");
    if (header) {
      var onScroll = function () {
        header.classList.toggle("is-scrolled", window.scrollY > 8);
      };
      onScroll();
      window.addEventListener("scroll", onScroll, { passive: true });
    }
  }

  /* ------------------------------------------------------------ docs nav */

  function initDocsSidebar() {
    var toggle = doc.querySelector("[data-sidebar-toggle]");
    var sidebar = doc.getElementById("docs-sidebar");
    if (!toggle || !sidebar) return;

    function close() {
      sidebar.classList.remove("is-open");
      toggle.setAttribute("aria-expanded", "false");
    }

    toggle.addEventListener("click", function () {
      var open = toggle.getAttribute("aria-expanded") === "true";
      if (open) {
        close();
      } else {
        sidebar.classList.add("is-open");
        toggle.setAttribute("aria-expanded", "true");
      }
    });

    sidebar.addEventListener("click", function (event) {
      if (event.target.closest("a") && window.matchMedia("(max-width: 820px)").matches) {
        close();
      }
    });

    doc.addEventListener("keydown", function (event) {
      if (event.key === "Escape") close();
    });

    doc.addEventListener("click", function (event) {
      if (
        sidebar.classList.contains("is-open") &&
        !event.target.closest("#docs-sidebar") &&
        !event.target.closest("[data-sidebar-toggle]")
      ) {
        close();
      }
    });
  }

  /* ------------------------------------------------------------ copy code */

  function fallbackCopy(text, done) {
    var area = doc.createElement("textarea");
    area.value = text;
    area.setAttribute("readonly", "");
    area.style.position = "fixed";
    area.style.top = "-1000px";
    area.style.opacity = "0";
    doc.body.appendChild(area);
    area.select();
    var ok = false;
    try {
      ok = doc.execCommand("copy");
    } catch (err) {
      ok = false;
    }
    doc.body.removeChild(area);
    done(ok);
  }

  function copyText(text, button) {
    function finish(ok) {
      button.textContent = ok ? "Copied" : "Select code";
      button.classList.toggle("is-copied", ok);
      window.setTimeout(function () {
        button.textContent = "Copy";
        button.classList.remove("is-copied");
      }, 1800);
    }

    if (navigator.clipboard && window.isSecureContext) {
      navigator.clipboard.writeText(text).then(
        function () {
          finish(true);
        },
        function () {
          fallbackCopy(text, finish);
        }
      );
    } else {
      fallbackCopy(text, finish);
    }
  }

  function initCopyButtons() {
    var blocks = doc.querySelectorAll("pre:not([data-no-copy])");
    blocks.forEach(function (pre) {
      if (pre.closest(".terminal-screen") || pre.closest(".install-panel")) return;
      if (pre.parentElement && pre.parentElement.classList.contains("code-shell")) return;

      var code = pre.querySelector("code");
      var lang = "";
      if (code && code.getAttribute("data-lang")) {
        lang = code.getAttribute("data-lang");
      } else if (pre.getAttribute("data-lang")) {
        lang = pre.getAttribute("data-lang");
      }

      var shell = doc.createElement("div");
      shell.className = "code-shell";
      shell.setAttribute("data-lang", lang || "shell");
      pre.parentNode.insertBefore(shell, pre);
      shell.appendChild(pre);

      var button = doc.createElement("button");
      button.type = "button";
      button.className = "copy-btn";
      button.textContent = "Copy";
      button.setAttribute("aria-label", "Copy code to clipboard");
      button.addEventListener("click", function () {
        copyText(pre.innerText.replace(/\n$/, ""), button);
      });
      shell.appendChild(button);
    });
  }

  /* ------------------------------------------------------------ docs search */

  function initSearch() {
    var input = doc.querySelector("[data-docs-search]");
    var results = doc.querySelector("[data-search-results]");
    var index = window.EERGN_SEARCH_INDEX;
    if (!input || !results || !Array.isArray(index)) return;

    var items = index.slice();

    function render(query) {
      var q = query.trim().toLowerCase();
      results.innerHTML = "";
      if (q.length < 2) {
        results.hidden = true;
        return;
      }

      var matches = items
        .filter(function (item) {
          var haystack = [item.title, item.description, item.keywords || "", item.category || ""]
            .join(" ")
            .toLowerCase();
          return haystack.indexOf(q) !== -1;
        })
        .slice(0, 9);

      results.hidden = false;

      if (!matches.length) {
        var empty = doc.createElement("div");
        empty.className = "search-empty";
        empty.textContent = 'No pages match "' + query.trim() + '". Try "nmap", "install" or "tls".';
        results.appendChild(empty);
        return;
      }

      matches.forEach(function (item) {
        var link = doc.createElement("a");
        link.className = "search-result";
        link.href = resolve(item.path);
        var title = doc.createElement("strong");
        title.textContent = item.title;
        var desc = doc.createElement("span");
        desc.textContent = item.description;
        link.appendChild(title);
        link.appendChild(desc);
        results.appendChild(link);
      });
    }

    input.addEventListener("input", function () {
      render(input.value);
    });

    input.addEventListener("keydown", function (event) {
      if (event.key === "Escape") {
        input.value = "";
        results.hidden = true;
        input.blur();
      }
      if (event.key === "Enter") {
        var first = results.querySelector("a");
        if (first && !results.hidden) {
          event.preventDefault();
          first.click();
        }
      }
    });

    doc.addEventListener("click", function (event) {
      if (!event.target.closest(".docs-search")) results.hidden = true;
    });
  }

  /* ------------------------------------------------------------ table of contents */

  function slugify(text) {
    return text
      .toLowerCase()
      .replace(/[^\w\s-]/g, "")
      .trim()
      .replace(/\s+/g, "-");
  }

  function initToc() {
    var toc = doc.querySelector("[data-toc]");
    var prose = doc.querySelector(".prose");
    if (!toc || !prose) return;

    var headings = Array.prototype.slice
      .call(prose.querySelectorAll("h2, h3"))
      .filter(function (heading) {
        return !heading.closest(".tool-card, .empty-state");
      });

    if (!headings.length) {
      toc.hidden = true;
      return;
    }

    var label = doc.createElement("p");
    label.textContent = "On this page";
    toc.appendChild(label);

    var links = [];
    headings.forEach(function (heading) {
      if (!heading.id) {
        var id = slugify(heading.textContent);
        var unique = id;
        var n = 2;
        while (doc.getElementById(unique)) {
          unique = id + "-" + n;
          n += 1;
        }
        heading.id = unique;
      }
      var link = doc.createElement("a");
      link.href = "#" + heading.id;
      link.textContent = heading.textContent;
      if (heading.tagName === "H3") link.className = "toc-h3";
      toc.appendChild(link);
      links.push({ link: link, heading: heading });
    });

    if ("IntersectionObserver" in window) {
      var observer = new IntersectionObserver(
        function (entries) {
          entries.forEach(function (entry) {
            if (!entry.isIntersecting) return;
            links.forEach(function (item) {
              item.link.classList.toggle("is-active", item.heading === entry.target);
            });
          });
        },
        { rootMargin: "-88px 0px -70% 0px", threshold: 0 }
      );
      headings.forEach(function (heading) {
        observer.observe(heading);
      });
    }
  }

  /* ------------------------------------------------------------ tool catalog */

  function initCatalog() {
    var cards = Array.prototype.slice.call(doc.querySelectorAll("[data-tool-card]"));
    var search = doc.querySelector("[data-tool-search]");
    var filterButtons = Array.prototype.slice.call(doc.querySelectorAll("[data-filter]"));
    var count = doc.querySelector("[data-tool-count]");
    var empty = doc.querySelector("[data-tool-empty]");
    if (!cards.length) return;

    var activeCategory = "all";

    function apply() {
      var q = search ? search.value.trim().toLowerCase() : "";
      var visible = 0;

      cards.forEach(function (card) {
        var category = card.getAttribute("data-category") || "";
        var haystack = [
          card.getAttribute("data-keywords") || "",
          card.textContent || ""
        ]
          .join(" ")
          .toLowerCase();
        var matchesCategory = activeCategory === "all" || category === activeCategory;
        var matchesQuery = !q || haystack.indexOf(q) !== -1;
        var show = matchesCategory && matchesQuery;
        card.hidden = !show;
        if (show) visible += 1;
      });

      if (count) {
        count.textContent = visible + " of " + cards.length + " tools";
      }
      if (empty) empty.hidden = visible !== 0;
    }

    filterButtons.forEach(function (button) {
      button.addEventListener("click", function () {
        activeCategory = button.getAttribute("data-filter") || "all";
        filterButtons.forEach(function (other) {
          other.setAttribute("aria-pressed", String(other === button));
        });
        apply();
      });
    });

    if (search) {
      search.addEventListener("input", apply);
    }

    apply();
  }

  onReady(function () {
    initHeaderNav();
    initDocsSidebar();
    initCopyButtons();
    initSearch();
    initToc();
    initCatalog();
  });
})();
