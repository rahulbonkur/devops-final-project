function searchRecipes() {
    const query = document.getElementById('searchInput').value;
    const category = document.getElementById('categoryFilter').value;
    const budget = document.getElementById('budgetFilter').value;

    let url = '/search?';
    if (query) url += `q=${encodeURIComponent(query)}&`;
    if (category) url += `category=${encodeURIComponent(category)}&`;
    if (budget) url += `budget=${budget}&`;

    window.location.href = url;
}

document.addEventListener('DOMContentLoaded', function () {
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        searchInput.addEventListener('keypress', function (e) {
            if (e.key === 'Enter') {
                searchRecipes();
            }
        });
    }
});
