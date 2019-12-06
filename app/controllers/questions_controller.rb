class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]

  helper_method :question

  def index
    @questions = Question.all
  end

  def show
    @answer = question.answers.new
  end

  def new; end

  def edit; end

  def create
    @question = current_user.questions.new(question_params)

    if @question.save
      redirect_to @question, notice: 'Your question successfully created.'
    else
      render :new
    end
  end

  def update
    if question.update(question_params)
      redirect_to question, notice: 'Your question successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    if current_user.is_author_of?(question)
      question.destroy
      redirect_to questions_path, notice: "Your question have been successfully destroyed."
    else
      redirect_to question, notice: 'No access to delete.'
    end
  end

  private

  def question
    @question ||= params[:id] ? Question.find(params[:id]) : current_user.questions.new
  end

  def question_params
    params.require(:question).permit(:title, :body)
  end
end
