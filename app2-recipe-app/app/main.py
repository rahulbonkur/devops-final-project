from flask import Flask, render_template, request, jsonify, redirect, url_for, flash
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import os

app = Flask(__name__)
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev-secret-key')
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL', 'sqlite:///recipes.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# Database Models
class Recipe(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text, nullable=False)
    ingredients = db.Column(db.Text, nullable=False)
    instructions = db.Column(db.Text, nullable=False)
    prep_time = db.Column(db.Integer, nullable=False)
    cook_time = db.Column(db.Integer, nullable=False)
    servings = db.Column(db.Integer, nullable=False)
    difficulty = db.Column(db.String(20), nullable=False)
    category = db.Column(db.String(50), nullable=False)
    budget = db.Column(db.Integer, nullable=False)
    calories = db.Column(db.Integer, nullable=True)
    equipment = db.Column(db.String(200), nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    rating = db.Column(db.Float, default=0)
    rating_count = db.Column(db.Integer, default=0)

class MealPlan(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    recipe_id = db.Column(db.Integer, db.ForeignKey('recipe.id'), nullable=False)
    day = db.Column(db.String(20), nullable=False)
    meal_type = db.Column(db.String(20), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    recipe = db.relationship('Recipe', backref='meal_plans')

with app.app_context():
    db.create_all()
    
    # Add sample recipes if database is empty
    if Recipe.query.count() == 0:
        sample_recipes = [
            Recipe(
                title="Quick Maggi Masala",
                description="The ultimate hostel favorite! Ready in 5 minutes, costs under ₹20",
                ingredients="1 pack Maggi noodles\n1 cup water\nTastemaker\nChopped onions (optional)\nGreen chili (optional)",
                instructions="1. Boil water in a pan\n2. Add Maggi and tastemaker\n3. Cook for 2 minutes\n4. Add chopped onions and chili\n5. Serve hot!",
                prep_time=1,
                cook_time=4,
                servings=1,
                difficulty="Easy",
                category="Quick Bites",
                budget=20,
                calories=310,
                equipment="Pan, Stove",
                rating=4.5,
                rating_count=150
            ),
            Recipe(
                title="Egg Bhurji",
                description="Protein-packed scrambled eggs Indian style. Perfect for breakfast or dinner!",
                ingredients="2 eggs\n1 onion, chopped\n1 tomato, chopped\nGreen chili\nSalt, turmeric, chili powder\n1 tbsp oil",
                instructions="1. Heat oil in pan\n2. Add onions, cook until golden\n3. Add tomatoes, cook until soft\n4. Add spices\n5. Beat eggs and add to pan\n6. Scramble and cook for 3 minutes",
                prep_time=5,
                cook_time=7,
                servings=1,
                difficulty="Easy",
                category="Breakfast",
                budget=30,
                calories=280,
                equipment="Pan, Stove",
                rating=4.7,
                rating_count=200
            ),
            Recipe(
                title="Budget Dal Rice",
                description="The classic comfort food! Cheap, nutritious, and filling",
                ingredients="1 cup dal (any)\n2 cups rice\nSalt, turmeric\n1 tsp ghee\nWater as needed",
                instructions="1. Pressure cook dal with salt and turmeric for 3 whistles\n2. Cook rice separately\n3. Mix cooked dal with rice\n4. Add ghee on top\n5. Serve hot",
                prep_time=5,
                cook_time=20,
                servings=2,
                difficulty="Easy",
                category="Main Course",
                budget=40,
                calories=450,
                equipment="Pressure cooker, Pot",
                rating=4.6,
                rating_count=180
            ),
            Recipe(
                title="Instant Oats Bowl",
                description="Healthy breakfast under 5 minutes! Great for gym-goers",
                ingredients="1/2 cup oats\n1 cup milk/water\nHoney\nBanana\nNuts (optional)",
                instructions="1. Boil milk/water\n2. Add oats and cook for 2 minutes\n3. Add honey\n4. Top with sliced banana and nuts\n5. Serve warm",
                prep_time=2,
                cook_time=3,
                servings=1,
                difficulty="Easy",
                category="Breakfast",
                budget=35,
                calories=320,
                equipment="Pan, Bowl",
                rating=4.4,
                rating_count=120
            ),
            Recipe(
                title="Bread Pizza",
                description="No oven needed! Make pizza on a pan in 10 minutes",
                ingredients="2 bread slices\nPizza sauce/ketchup\nGrated cheese\nChopped vegetables\nOregano",
                instructions="1. Spread sauce on bread\n2. Add vegetables and cheese\n3. Heat pan on low flame\n4. Place bread pizza in pan\n5. Cover and cook for 5 minutes\n6. Sprinkle oregano and serve",
                prep_time=5,
                cook_time=5,
                servings=1,
                difficulty="Easy",
                category="Quick Bites",
                budget=40,
                calories=380,
                equipment="Pan with lid",
                rating=4.8,
                rating_count=250
            )
        ]
        db.session.bulk_save_objects(sample_recipes)
        db.session.commit()

@app.route('/')
def index():
    recipes = Recipe.query.order_by(Recipe.rating.desc()).all()
    return render_template('index.html', recipes=recipes)

@app.route('/recipe/<int:id>')
def recipe_detail(id):
    recipe = Recipe.query.get_or_404(id)
    return render_template('recipe_detail.html', recipe=recipe)

@app.route('/add', methods=['GET', 'POST'])
def add_recipe():
    if request.method == 'POST':
        recipe = Recipe(
            title=request.form['title'],
            description=request.form['description'],
            ingredients=request.form['ingredients'],
            instructions=request.form['instructions'],
            prep_time=int(request.form['prep_time']),
            cook_time=int(request.form['cook_time']),
            servings=int(request.form['servings']),
            difficulty=request.form['difficulty'],
            category=request.form['category'],
            budget=int(request.form['budget']),
            calories=int(request.form.get('calories', 0)),
            equipment=request.form.get('equipment', '')
        )
        db.session.add(recipe)
        db.session.commit()
        flash('Recipe added successfully!', 'success')
        return redirect(url_for('index'))
    return render_template('add_recipe.html')

@app.route('/search')
def search():
    query = request.args.get('q', '')
    category = request.args.get('category', '')
    max_budget = request.args.get('budget', type=int)
    
    recipes = Recipe.query
    
    if query:
        recipes = recipes.filter(Recipe.title.contains(query) | Recipe.description.contains(query))
    if category:
        recipes = recipes.filter_by(category=category)
    if max_budget:
        recipes = recipes.filter(Recipe.budget <= max_budget)
    
    recipes = recipes.all()
    return render_template('search_results.html', recipes=recipes, query=query)

@app.route('/api/recipes')
def api_recipes():
    recipes = Recipe.query.all()
    return jsonify([{
        'id': r.id,
        'title': r.title,
        'description': r.description,
        'budget': r.budget,
        'prep_time': r.prep_time,
        'category': r.category,
        'rating': r.rating
    } for r in recipes])

@app.route('/api/rate/<int:id>', methods=['POST'])
def rate_recipe(id):
    recipe = Recipe.query.get_or_404(id)
    rating = request.json.get('rating', 0)
    
    if 1 <= rating <= 5:
        total_rating = recipe.rating * recipe.rating_count
        recipe.rating_count += 1
        recipe.rating = (total_rating + rating) / recipe.rating_count
        db.session.commit()
        return jsonify({'success': True, 'new_rating': round(recipe.rating, 1)})
    
    return jsonify({'success': False}), 400

@app.route('/meal-plan')
def meal_plan():
    days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    meal_types = ['Breakfast', 'Lunch', 'Dinner']
    
    plan = {}
    for day in days:
        plan[day] = {}
        for meal_type in meal_types:
            meal = MealPlan.query.filter_by(day=day, meal_type=meal_type).first()
            plan[day][meal_type] = meal.recipe if meal else None
    
    return render_template('meal_plan.html', plan=plan, days=days, meal_types=meal_types)

@app.route('/health')
def health():
    return jsonify({'status': 'healthy', 'timestamp': datetime.utcnow().isoformat()})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
