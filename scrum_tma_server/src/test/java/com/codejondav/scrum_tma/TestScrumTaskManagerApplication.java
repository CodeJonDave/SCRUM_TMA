package com.codejondav.scrum_tma;

import org.springframework.boot.SpringApplication;

public class TestScrumTaskManagerApplication {

	public static void main(String[] args) {
		SpringApplication.from(ScrumTaskManagerApplication::main).with(TestcontainersConfiguration.class).run(args);
	}

}
