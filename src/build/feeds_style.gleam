//// Browser-friendly XSL stylesheets for Atom and RSS feeds.
////
//// These stylesheets are emitted as static files into `dist/` and referenced
//// from `atom.xml` / `rss.xml` through an XML stylesheet processing
//// instruction.
////
//// The stylesheets intentionally use XSLT 1.0 because that is the level
//// broadly supported by browser-native XML/XSLT renderers.

/// XSL stylesheet for `atom.xml`.
pub fn atom_xsl() -> String {
  "<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet
  version='1.0'
  xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
  xmlns:atom='http://www.w3.org/2005/Atom'>

  <xsl:output method='html' encoding='UTF-8' indent='yes'/>

  <xsl:template match='/'>
    <html>
      <head>
        <meta charset='UTF-8'/>
        <meta name='viewport' content='width=device-width, initial-scale=1'/>
        <title><xsl:value-of select='/atom:feed/atom:title'/> — Atom Feed</title>
        <style>
          :root {
            color-scheme: light dark;
            --bg: #f8f8f8;
            --surface: #ffffff;
            --text: #1f2328;
            --muted: #656d76;
            --border: #d0d7de;
            --primary: #3555b3;
          }

          @media (prefers-color-scheme: dark) {
            :root {
              --bg: #0f1115;
              --surface: #171a21;
              --text: #e6edf3;
              --muted: #9aa4b2;
              --border: #30363d;
              --primary: #8aa2ff;
            }
          }

          * {
            box-sizing: border-box;
          }

          body {
            margin: 0;
            padding: 2rem 1rem;
            background: var(--bg);
            color: var(--text);
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            line-height: 1.6;
          }

          main {
            max-width: 760px;
            margin: 0 auto;
          }

          header {
            margin-bottom: 2rem;
          }

          h1 {
            margin: 0 0 0.5rem;
            font-size: clamp(1.8rem, 6vw, 3rem);
            line-height: 1.1;
          }

          p {
            margin: 0.75rem 0;
          }

          a {
            color: var(--primary);
            text-decoration-thickness: 0.08em;
            text-underline-offset: 0.18em;
          }

          code {
            display: inline-block;
            max-width: 100%;
            overflow-x: auto;
            padding: 0.25rem 0.45rem;
            border: 1px solid var(--border);
            border-radius: 0.4rem;
            background: var(--surface);
            color: var(--text);
            font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
            font-size: 0.9rem;
            white-space: nowrap;
          }

          .feed-note {
            color: var(--muted);
          }

          .entries {
            display: grid;
            gap: 0.75rem;
            margin-top: 1.5rem;
          }

          details {
            border: 1px solid var(--border);
            border-radius: 0.75rem;
            background: var(--surface);
            padding: 0.85rem 1rem;
          }

          summary {
            cursor: pointer;
            font-weight: 700;
          }

          .date {
            color: var(--muted);
            font-size: 0.9rem;
            font-weight: 400;
          }

          .summary {
            margin-top: 0.75rem;
            color: var(--muted);
          }

          footer {
            margin-top: 2rem;
            color: var(--muted);
            font-size: 0.9rem;
          }
        </style>
      </head>

      <body>
        <main>
          <header>
            <h1><xsl:value-of select='/atom:feed/atom:title'/></h1>

            <p>
              <xsl:value-of select='/atom:feed/atom:subtitle'/>
            </p>

            <p class='feed-note'>
              This is the Atom feed for
              <a>
                <xsl:attribute name='href'>
                  <xsl:value-of select='/atom:feed/atom:link[@rel=\"alternate\"]/@href | /atom:feed/atom:link[not(@rel)]/@href'/>
                </xsl:attribute>
                <xsl:value-of select='/atom:feed/atom:title'/>
              </a>.
              Copy this URL into your feed reader:
            </p>

            <p>
              <code><xsl:value-of select='/atom:feed/atom:link[@rel=\"self\"]/@href'/></code>
            </p>
          </header>

          <section class='entries'>
            <xsl:for-each select='/atom:feed/atom:entry'>
              <details>
                <summary>
                  <a>
                    <xsl:attribute name='href'>
                      <xsl:value-of select='atom:link/@href'/>
                    </xsl:attribute>
                    <xsl:value-of select='atom:title'/>
                  </a>
                  <span class='date'>
                    —
                    <xsl:value-of select='atom:updated'/>
                  </span>
                </summary>

                <p class='summary'>
                  <xsl:value-of select='atom:summary'/>
                </p>
              </details>
            </xsl:for-each>
          </section>

          <footer>
            <xsl:value-of select='count(/atom:feed/atom:entry)'/> feed entries.
          </footer>
        </main>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>"
}

/// XSL stylesheet for `rss.xml`.
pub fn rss_xsl() -> String {
  "<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet
  version='1.0'
  xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
  xmlns:atom='http://www.w3.org/2005/Atom'>

  <xsl:output method='html' encoding='UTF-8' indent='yes'/>

  <xsl:template match='/'>
    <html>
      <head>
        <meta charset='UTF-8'/>
        <meta name='viewport' content='width=device-width, initial-scale=1'/>
        <title><xsl:value-of select='/rss/channel/title'/> — RSS Feed</title>
        <style>
          :root {
            color-scheme: light dark;
            --bg: #f8f8f8;
            --surface: #ffffff;
            --text: #1f2328;
            --muted: #656d76;
            --border: #d0d7de;
            --primary: #3555b3;
          }

          @media (prefers-color-scheme: dark) {
            :root {
              --bg: #0f1115;
              --surface: #171a21;
              --text: #e6edf3;
              --muted: #9aa4b2;
              --border: #30363d;
              --primary: #8aa2ff;
            }
          }

          * {
            box-sizing: border-box;
          }

          body {
            margin: 0;
            padding: 2rem 1rem;
            background: var(--bg);
            color: var(--text);
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            line-height: 1.6;
          }

          main {
            max-width: 760px;
            margin: 0 auto;
          }

          header {
            margin-bottom: 2rem;
          }

          h1 {
            margin: 0 0 0.5rem;
            font-size: clamp(1.8rem, 6vw, 3rem);
            line-height: 1.1;
          }

          p {
            margin: 0.75rem 0;
          }

          a {
            color: var(--primary);
            text-decoration-thickness: 0.08em;
            text-underline-offset: 0.18em;
          }

          code {
            display: inline-block;
            max-width: 100%;
            overflow-x: auto;
            padding: 0.25rem 0.45rem;
            border: 1px solid var(--border);
            border-radius: 0.4rem;
            background: var(--surface);
            color: var(--text);
            font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
            font-size: 0.9rem;
            white-space: nowrap;
          }

          .feed-note {
            color: var(--muted);
          }

          .entries {
            display: grid;
            gap: 0.75rem;
            margin-top: 1.5rem;
          }

          details {
            border: 1px solid var(--border);
            border-radius: 0.75rem;
            background: var(--surface);
            padding: 0.85rem 1rem;
          }

          summary {
            cursor: pointer;
            font-weight: 700;
          }

          .date {
            color: var(--muted);
            font-size: 0.9rem;
            font-weight: 400;
          }

          .summary {
            margin-top: 0.75rem;
            color: var(--muted);
          }

          footer {
            margin-top: 2rem;
            color: var(--muted);
            font-size: 0.9rem;
          }
        </style>
      </head>

      <body>
        <main>
          <header>
            <h1><xsl:value-of select='/rss/channel/title'/></h1>

            <p>
              <xsl:value-of select='/rss/channel/description'/>
            </p>

            <p class='feed-note'>
              This is the RSS feed for
              <a>
                <xsl:attribute name='href'>
                  <xsl:value-of select='/rss/channel/link'/>
                </xsl:attribute>
                <xsl:value-of select='/rss/channel/title'/>
              </a>.
              Copy this URL into your feed reader:
            </p>

            <p>
              <code><xsl:value-of select='/rss/channel/atom:link[@rel=\"self\"]/@href'/></code>
            </p>
          </header>

          <section class='entries'>
            <xsl:for-each select='/rss/channel/item'>
              <details>
                <summary>
                  <a>
                    <xsl:attribute name='href'>
                      <xsl:value-of select='link'/>
                    </xsl:attribute>
                    <xsl:value-of select='title'/>
                  </a>
                  <span class='date'>
                    —
                    <xsl:value-of select='pubDate'/>
                  </span>
                </summary>

                <p class='summary'>
                  <xsl:value-of select='description'/>
                </p>
              </details>
            </xsl:for-each>
          </section>

          <footer>
            <xsl:value-of select='count(/rss/channel/item)'/> feed entries.
          </footer>
        </main>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>"
}
