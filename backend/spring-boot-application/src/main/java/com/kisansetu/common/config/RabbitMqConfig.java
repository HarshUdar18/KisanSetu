package com.kisansetu.common.config;

import org.springframework.amqp.core.*;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

@Configuration
@Profile("!test")
public class RabbitMqConfig {

    public static final String EXCHANGE_KISANSETU_EVENTS = "kisansetu.events";
    public static final String EXCHANGE_DLX = "kisansetu.dlx";
    public static final String QUEUE_DLQ = "kisansetu.dlq";
    public static final String QUEUE_DOMAIN_EVENTS = "kisansetu.queue.domain";

    @Bean
    public TopicExchange eventsExchange() {
        return new TopicExchange(EXCHANGE_KISANSETU_EVENTS, true, false);
    }

    @Bean
    public DirectExchange deadLetterExchange() {
        return new DirectExchange(EXCHANGE_DLX, true, false);
    }

    @Bean
    public Queue deadLetterQueue() {
        return QueueBuilder.durable(QUEUE_DLQ).build();
    }

    @Bean
    public Binding dlqBinding() {
        return BindingBuilder.bind(deadLetterQueue()).to(deadLetterExchange()).with("dlq");
    }

    @Bean
    public Queue domainEventsQueue() {
        return QueueBuilder.durable(QUEUE_DOMAIN_EVENTS)
                .withArgument("x-dead-letter-exchange", EXCHANGE_DLX)
                .withArgument("x-dead-letter-routing-key", "dlq")
                .build();
    }

    @Bean
    public Binding domainEventsBinding() {
        return BindingBuilder.bind(domainEventsQueue()).to(eventsExchange()).with("#");
    }

    @Bean
    public MessageConverter jsonMessageConverter() {
        return new Jackson2JsonMessageConverter();
    }

    @Bean
    public RabbitTemplate rabbitTemplate(ConnectionFactory connectionFactory) {
        RabbitTemplate template = new RabbitTemplate(connectionFactory);
        template.setMessageConverter(jsonMessageConverter());
        return template;
    }
}
