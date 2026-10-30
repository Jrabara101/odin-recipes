class KittensController < ApplicationController
  before_action :set_kitten, only: %i[show edit update destroy]

  # GET /kittens
  # GET /kittens.json
  def index
    @kittens = Kitten.all.order(created_at: :desc)

    respond_to do |format|
      format.html
      format.json { render json: @kittens }
    end
  end

  # GET /kittens/:id
  # GET /kittens/:id.json
  def show
    respond_to do |format|
      format.html
      format.json { render json: @kitten }
    end
  end

  # GET /kittens/new
  def new
    @kitten = Kitten.new(age: 1, cuteness: 10, softness: 10)
  end

  # POST /kittens
  def create
    @kitten = Kitten.new(kitten_params)

    if @kitten.save
      flash[:success] = "🎉 Purr-fection! #{@kitten.name} has been welcomed into the sanctuary! Welcome to the cuddle squad! 🐾"
      redirect_to @kitten
    else
      flash.now[:alert] = "😿 Meow-uch! Did a cat walk across your keyboard? Your form has errors! Check below to fix them."
      render :new, status: :unprocessable_entity
    end
  end

  # GET /kittens/:id/edit
  def edit
  end

  # PATCH/PUT /kittens/:id
  def update
    if @kitten.update(kitten_params)
      flash[:success] = "✨ Snazzy! #{@kitten.name} received a fabulous makeover! Paws-itively glowing! 🐱"
      redirect_to @kitten
    else
      flash.now[:alert] = "🙀 Hiss! You botched the makeover! Even a hairless sphynx would be embarrassed. Correct the errors below:"
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /kittens/:id
  def destroy
    name = @kitten.name
    @kitten.destroy
    flash[:notice] = "👋 Farewell, #{name}! Off to take a 16-hour nap in a sunny patch of grass or conquer a fresh cardboard box! 📦"
    redirect_to kittens_path, status: :see_other
  end

  private

  def set_kitten
    @kitten = Kitten.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "🔍 That kitten could not be found! It might have squeezed under the couch."
    redirect_to kittens_path
  end

  def kitten_params
    params.require(:kitten).permit(:name, :age, :cuteness, :softness)
  end
end
