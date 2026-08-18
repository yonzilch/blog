<?xml version='1.0' encoding='UTF-8'?>
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
        <script><![CDATA[
(function(){var theme=null;try{theme=window.localStorage.getItem('theme-storage');}catch(_){theme=null;}if(theme!=='light'&&theme!=='dark'&&theme!=='auto'){theme='auto';}var dark=theme==='dark';if(theme==='auto'){try{dark=window.matchMedia('(prefers-color-scheme: dark)').matches;}catch(_){dark=false;}}document.documentElement.classList.toggle('dark',dark);})();
]]></script>
        <style>
          :root {
    color-scheme: light;

    --bg-0: #ffffff;
    --bg-1: #f7f7f7;

    --text-0: #111827;
    --text-2: #4b5563;
    --body-text: #151515de;

    --border-color: #d1d5db;
    --primary-color: #2f4fa3;
  }

  :root.dark {
    color-scheme: dark;

    --bg-0: #0f1115;
    --bg-1: #171a21;

    --text-0: #f8fafc;
    --text-2: #a1a1aa;
    --body-text: #f8fafce0;

    --border-color: #374151;
    --primary-color: #5f7eea;
  }

          * {
    box-sizing: border-box;
  }

  html {
    min-height: 100%;
    background: var(--bg-0);
  }

  body {
    min-height: 100%;
    margin: 0;
    padding: 2rem 1rem;
    background: var(--bg-0);
    color: var(--body-text);
    font-family:
      -apple-system,
      BlinkMacSystemFont,
      'Segoe UI',
      sans-serif;
    line-height: 1.6;
  }

  main {
    width: 100%;
    max-width: 760px;
    margin: 0 auto;
  }

  header {
    margin-bottom: 2rem;
  }

  h1 {
    margin: 0 0 0.5rem;
    color: var(--text-0);
    font-size: clamp(1.8rem, 6vw, 3rem);
    line-height: 1.1;
  }

  p {
    margin: 0.75rem 0;
  }

  a {
    color: var(--primary-color);
    text-decoration-thickness: 0.08em;
    text-underline-offset: 0.18em;
  }

  code {
    display: inline-block;
    max-width: 100%;
    overflow-x: auto;
    padding: 0.25rem 0.45rem;
    border: 1px solid var(--border-color);
    border-radius: 0.4rem;
    background: var(--bg-1);
    color: var(--text-0);
    font-family:
      ui-monospace,
      SFMono-Regular,
      Menlo,
      Consolas,
      monospace;
    font-size: 0.9rem;
    white-space: nowrap;
  }

  .feed-note {
    color: var(--text-2);
  }

  .entries {
    display: grid;
    gap: 0.75rem;
    margin-top: 1.5rem;
  }

  details {
    padding: 0.85rem 1rem;
    border: 1px solid var(--border-color);
    border-radius: 0.75rem;
    background: var(--bg-1);
  }

  summary {
    color: var(--text-0);
    cursor: pointer;
    font-weight: 700;
  }

  .date {
    color: var(--text-2);
    font-size: 0.9rem;
    font-weight: 400;
  }

  .summary {
    margin-top: 0.75rem;
    color: var(--text-2);
  }

  footer {
    margin-top: 2rem;
    color: var(--text-2);
    font-size: 0.9rem;
  }

  @media all and (max-width: 640px) {
    body {
      padding: 1.5rem 0.85rem;
    }

    details {
      padding: 0.8rem 0.85rem;
      border-radius: 0.65rem;
    }

    .date {
      display: block;
      margin-top: 0.2rem;
    }
  }
        </style>
      </head>

      <body>
        <main>
          <header>
            <h1>
              <xsl:value-of select='/rss/channel/title'/>
            </h1>

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
              <code>
                <xsl:value-of select='/rss/channel/atom:link[@rel="self"]/@href'/>
              </code>
            </p>
          </header>

          <section class='entries'>
            <xsl:for-each select='/rss/channel/item'>
              <details>
                <summary>
                  <a target='_blank' rel='noopener noreferrer'>
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
</xsl:stylesheet>