class GamesController < ApplicationController
    def intro
        render :'index'
    end

    def create
        #create a new game and add the first question
        @game = Game.create(user_id: user_params[:user_id], genre: question_params[:genre])
        @game.get_unique_question(@game.genre)

        redirect_to "/game/#{@game.id}/question/#{@game.questions.first.id}"
    end

    def answer
        #adds to score, redirects to answer page, 
        #answer page redirects to next question's show page
        @game = Game.find(game_params[:game_id])
        @game_question = @game.game_questions.last
        @question = Question.find_by(title: question_params[:title])
        
        @simple_answer = @question.simplify_title
        @answer = (game_params[:answer].split(" ")).map {|word| word.downcase}
        if @simple_answer.all? {|word| @answer.include?(word)}
            flash[:feedback] = "🎊RIGHT! Way to go!🎉"
            @game_question.update(correct: true)
        else flash[:feedback] = "WRONG! sorry! 😢"
        end

        flash[:correct] = question_params[:title]
        flash[:game] = Game.find(game_params[:game_id])
        flash[:question] = Question.find(question_params[:question_id])
       
        redirect_to :action => "show_answer"
    end

    def show_answer
        @game_id = flash[:game].values.first
        @game = Game.find(@game_id)
        unless @game.game_over? 
            @game.get_unique_question(@game.genre)
        end

        @next_question = @game.questions[-1].id
        @question = flash[:question]

        render :'questions/answer'
    end

    def leaderboard
        @user_gamescores = Game.leaderboard
    end

    def end_game
        @game = Game.find(params[:game_id])

        #add that if game score is not highest score of player or in leaderboard, delete

        render :'games/game_over'
    end

private

    def game_params
        params.require(:game).permit(:answer, :game_id, :score)
    end

    def question_params
        params.require(:question).permit(:title, :question_id, :genre)
    end

    def user_params
        params.require(:user).permit(:user_id)
    end
end