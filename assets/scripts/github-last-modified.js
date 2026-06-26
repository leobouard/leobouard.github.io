(function () {
  'use strict';

  function formatDate(dateString) {
    var date = new Date(dateString);
    if (Number.isNaN(date.getTime())) return null;

    var options = { day: 'numeric', month: 'long', year: 'numeric' };
    return date.toLocaleDateString('fr-FR', options);
  }

  function getLastModifiedElement() {
    return document.querySelector('[data-gh-last-modified="true"]');
  }

  function buildApiUrl(owner, repo, branch, path) {
    var encodedPath = encodeURIComponent(path);
    return 'https://api.github.com/repos/' + owner + '/' + repo + '/commits?path=' + encodedPath + '&sha=' + encodeURIComponent(branch) + '&per_page=1';
  }

  function setModifiedText(element, text) {
    element.textContent = text;
  }

  function fetchLastModified(owner, repo, branch, path, element) {
    var url = buildApiUrl(owner, repo, branch, path);

    fetch(url, {
      headers: {
        Accept: 'application/vnd.github.v3+json'
      }
    })
      .then(function (response) {
        if (!response.ok) {
          throw new Error('GitHub API ' + response.status);
        }
        return response.json();
      })
      .then(function (commits) {
        if (!Array.isArray(commits) || commits.length === 0 || !commits[0].commit) {
          throw new Error('Aucun commit trouvé');
        }
        var date = commits[0].commit.committer.date || commits[0].commit.author.date;
        var formatted = formatDate(date);
        if (!formatted) {
          throw new Error('Date invalide');
        }
        var textSpan = element.querySelector('.article-info-modified-text');
        if (textSpan) {
          textSpan.textContent = 'Modifié le ' + formatted;
        }
      })
      .catch(function () {
        var textSpan = element.querySelector('.article-info-modified-text');
        if (textSpan) {
          textSpan.textContent = 'Date de modification indisponible';
        }
      });
  }

  document.addEventListener('DOMContentLoaded', function () {
    var element = getLastModifiedElement();
    if (!element) return;

    var owner = element.dataset.ghOwner;
    var repo = element.dataset.ghRepo;
    var branch = element.dataset.ghBranch;
    var path = element.dataset.ghPath;

    if (!owner || !repo || !branch || !path) {
      return;
    }

    fetchLastModified(owner, repo, branch, path, element);
  });
})();
