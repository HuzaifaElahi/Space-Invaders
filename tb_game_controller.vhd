-----------------------------------
-- Author: Muhammad Huzaifa Elahi and Usaid Barlas
-- Email: muhammad.h.elahi@mail.mcgill.ca and usaid.barlas@mail.mcgill.ca

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

library modelsim_lib;
use modelsim_lib.util.all;

-- Declare test-base entity
entity tb_game_controller is 
end tb_game_controller;

architecture behaviour of tb_game_controller is
-- Declare Device Under Test as a component here 
	component game_controller is
		port (
		  clk             : in std_logic; -- Clock for the system
       		  rst             : in std_logic; -- Resets the state machine

       		 -- Inputs
       		  shoot           : in std_logic; -- User shoot
       		  move_left       : in std_logic; -- User left
        	  move_right      : in std_logic; -- User right
		  
		  pixel_x         : in integer; -- X position of the cursor
		  pixel_y	  : in integer; -- Y position of the cursor
        
		  -- Outputs
       		  pixel_color	  : out std_logic_vector (2 downto 0);
		  game_state 	  : out integer -- 0 for init, 1 for pre-game, 2 for gameplay, and 3 for game_over
         );
	end component;


-- Inputs 
signal clk_in:	std_logic;
signal rst_in:	std_logic;
signal shoot_in: std_logic;
signal move_left_in: std_logic;
signal move_right_in: std_logic;
signal pixel_x_in : integer;
signal pixel_y_in : integer;



--Output 
signal pixel_color_out :  std_logic_vector (2 downto 0);
signal game_state :  integer; 

--Helper 
constant clk_period: time :=10 ns;

begin 

game_controller_instance: game_controller
	port map (
		clk => clk_in,
		rst => rst_in,
		shoot => shoot_in,
		move_left => move_left_in,
		move_right => move_right_in,
		pixel_x => pixel_x_in,
		pixel_y => pixel_y_in,
		pixel_color => pixel_color_out,
		game_state => game_state
	);
	-- Recreate a clock signal here
	clk_process: process
	begin
		clk_in <= '0';
		wait for clk_period/2;
		clk_in <= '1';
		wait for clk_period/2;
	end process;

	
	--reset puts init
	test: process
	begin
	
	--init.
        rst_in <= '1';
	wait for clk_period;
	wait for clk_period;
	assert game_state = 0 report "Error with change to init" severity Error;
	

	--pre-game instantly
	rst_in <= '0';
	wait for clk_period;
	assert game_state = 1 report "Error with change to pre_game" severity Error;

	--gameplay
	shoot_in <= '1';
	wait for clk_period;
	assert game_state = 2 report "Error with change to game_play" severity Error;

	--Decrement the lives till game_over
	signal_force("tb_game_controller/game_controller_instance/num_lives","2");
	wait for clk_period;
	signal_force("tb_game_controller/game_controller_instance/num_lives","1");
	wait for clk_period;
	signal_force("tb_game_controller/game_controller_instance/num_lives","0");
	wait for clk_period;
	assert game_state = 3 report "Error with change to game_over" severity Error;

	-- if the shoot button is pressed when gameover -> init state 
	shoot_in <= '1';
	wait for clk_period;
	assert game_state = 0 report "Error with change from gameplay to init" severity Error;

	assert false report "Test success" severity Failure;

	end process;
end behaviour;
