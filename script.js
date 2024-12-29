// Fetch the README.md content
fetch('README.md')
  .then(response => response.text())
  .then(markdown => {
    // Convert Markdown to HTML
    const converter = new showdown.Converter();
    const html = converter.makeHtml(markdown);

    // Inject HTML into the page
    document.getElementById('markdown-content').innerHTML = html;
  })
  .catch(error => console.error('Erro ao carregar o arquivo Markdown:', error));
